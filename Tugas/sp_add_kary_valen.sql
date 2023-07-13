CREATE PROCEDURE sp_add_kary_valen
(
  @Nip INT,
  @Nama VARCHAR(50),
  @Alamat VARCHAR(100),
  @Gend VARCHAR(10),
  @TanggalLahir DATE
)
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRANSACTION;

    -- Simpan data ke tabel karyawan
    INSERT INTO karyawan (Nip, Nama, Alamat, Gend, TanggalLahir)
    VALUES (@Nip, @Nama, @Alamat, @Gend, @TanggalLahir);

    -- Simpan data ke tabel log_trx_api
    INSERT INTO log_trx_api (ApiName, Result)
    VALUES ('sp_add_kary_valen', 'Berhasil');

    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK;

    -- Simpan data ke tabel log_trx_api
    INSERT INTO log_trx_api (ApiName, Result)
    VALUES ('sp_add_kary_valen', 'Gagal');

    THROW;
  END CATCH;
END;
