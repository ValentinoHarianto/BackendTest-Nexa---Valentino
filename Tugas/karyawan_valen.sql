CREATE VIEW karyawan_valen AS
SELECT
  ROW_NUMBER() OVER (ORDER BY Nip) AS No,
  Nip,
  Nama,
  Alamat,
  CASE WHEN Gend = 'L' THEN 'Laki - Laki' ELSE 'Perempuan' END AS Gend,
  CONVERT(VARCHAR(12), TanggalLahir, 106) AS 'Tanggal lahir (12 April 2023)'
FROM
  karyawan;
