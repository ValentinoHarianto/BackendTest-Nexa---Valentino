const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());

// Simulated database
const adminTable = [
  { username: 'testdata', password: 'databaru' } // Password: databaru
];

const adminTokens = [];

const karyawanTable = [];

const AES_KEY = 'nexatest';

// Middleware for token authentication
const authenticateToken = (req, res, next) => {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({ message: 'Authentication token missing' });
  }

  try {
    const decodedToken = jwt.verify(token, AES_KEY);
    req.adminId = decodedToken.adminId;
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Invalid token' });
  }
};

// Generate JWT token
const generateToken = (adminId) => {
  const token = jwt.sign({ adminId }, AES_KEY);
  return token;
};

// Endpoint to get authentication token
app.post('/auth', (req, res) => {
  const { username, password } = req.body;

  const admin = adminTable.find((admin) => admin.username === username);
  if (!admin || password !== admin.password) {
    return res.status(401).json({ message: 'Invalid username or password' });
  }

  const token = generateToken(admin.username);
  adminTokens.push(token);

  res.json({ token });
});

// Endpoint to register new karyawan
app.post('/karyawan', authenticateToken, (req, res) => {
  const { nama, photo } = req.body;

  // Generate NIP
  const year = new Date().getFullYear();
  const yearPrefix = year.toString().slice(-2);
  const nipCounter = karyawanTable.filter((karyawan) => karyawan.nip.startsWith(yearPrefix)).length + 1;
  const nip = `${yearPrefix}${nipCounter.toString().padStart(4, '0')}`;

  const newKaryawan = {
    nama,
    nip,
    photo,
  };

  karyawanTable.push(newKaryawan);

  res.json({ message: 'Karyawan registered successfully', karyawan: newKaryawan });
});

// Endpoint to get list of karyawan
app.get('/karyawan', authenticateToken, (req, res) => {
  const { keyword, start, count } = req.query;

  const startIndex = parseInt(start) || 0;
  const countValue = parseInt(count) || 10;

  let filteredKaryawan = karyawanTable;
  if (keyword) {
    const keywordRegex = new RegExp(keyword, 'i');
    filteredKaryawan = karyawanTable.filter((karyawan) => keywordRegex.test(karyawan.nama));
  }

  const paginatedKaryawan = filteredKaryawan.slice(startIndex, startIndex + countValue);

  res.json({ karyawan: paginatedKaryawan });
});

// Endpoint to update a karyawan
app.put('/karyawan/:nip', authenticateToken, (req, res) => {
  const { nip } = req.params;
  const { nama, photo } = req.body;

  const karyawan = karyawanTable.find((karyawan) => karyawan.nip === nip);
  if (!karyawan) {
    return res.status(404).json({ message: 'Karyawan not found' });
  }

  karyawan.nama = nama || karyawan.nama;
  karyawan.photo = photo || karyawan.photo;

  res.json({ message: 'Karyawan updated successfully', karyawan });
});

// Endpoint to deactivate a karyawan
app.put('/karyawan/deactivate/:nip', authenticateToken, (req, res) => {
  const { nip } = req.params;

  const karyawan = karyawanTable.find((karyawan) => karyawan.nip === nip);
  if (!karyawan) {
    return res.status(404).json({ message: 'Karyawan not found' });
  }

  karyawan.status = 9;

  res.json({ message: 'Karyawan deactivated successfully', karyawan });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error' });
});

// Start the server
app.listen(3000, () => {
  console.log('Server is listening on port 3000');
});
