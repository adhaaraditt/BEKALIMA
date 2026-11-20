/**
 * Ganti SELURUH isi Code.gs dengan file ini, lalu:
 * 1. Deploy > Manage deployments > Edit > Version: New version > Deploy.
 * 2. Baru hapus kolom "Alamat Utama" di tab User (urutan bebas, saveUser
 *    menulis berdasarkan nama header, jadi tidak ada data yang bergeser).
 * 3. Dropdown Status (H2:H) dipasang otomatis oleh script setiap ada aksi
 *    dari aplikasi, jadi tidak perlu Data validation manual lagi.
 *
 * Kolom tab Pesanan: A ID, B Tanggal, C Estimasi, D Penerima, E Telepon,
 * F Alamat, G Metode, H Status, I Total, J Items, K Catatan.
 * Kolom tab User dibaca berdasarkan header, bukan urutan.
 */

const ORDER_STATUSES = [
  "Menunggu Pembayaran",
  "Terbayar",
  "Dikirim",
  "Selesai",
  "Dibatalkan"
];

/**
 * Ambil tab Pesanan sekaligus pastikan kolom Status (H) punya dropdown.
 * Dipanggil di setiap aksi Pesanan supaya dropdown selalu ada.
 */
function getPesananSheet_(ss) {
  const sheet = getPesananSheet_(ss);
  if (!sheet) return null;

  const rule = SpreadsheetApp.newDataValidation()
    .requireValueInList(ORDER_STATUSES, true)
    .setAllowInvalid(false)
    .setHelpText("Pilih status pesanan.")
    .build();
  sheet
    .getRange(2, 8, Math.max(sheet.getMaxRows() - 1, 1), 1)
    .setDataValidation(rule);

  return sheet;
}

function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    const ss = SpreadsheetApp.getActiveSpreadsheet();

    // 1. Simpan Pesanan Baru
    if (data.action === "createOrder") {
      const sheet = getPesananSheet_(ss);
      const o = data.order;
      sheet.appendRow([
        o.id,
        o.orderDate,
        o.eventTime,
        o.recipientName,
        o.recipientPhone,
        o.deliveryAddress,
        o.paymentMethod,
        o.status,
        o.totalPrice,
        o.itemsSummary,
        o.notes || "-"
      ]);
      return responseJson({ status: "success" });
    }

    // 2. Update Status Pesanan
    if (data.action === "updateOrderStatus") {
      const sheet = getPesananSheet_(ss);
      const values = sheet.getDataRange().getValues();
      for (let i = 1; i < values.length; i++) {
        if (String(values[i][0]).trim() === String(data.orderId).trim()) {
          sheet.getRange(i + 1, 8).setValue(data.status); // H
          return responseJson({ status: "success" });
        }
      }
      return responseJson({ status: "not_found" });
    }

    // 3. Update Menu & Total Pesanan (hanya saat Menunggu Pembayaran)
    if (data.action === "updateOrderItems") {
      const sheet = getPesananSheet_(ss);
      const values = sheet.getDataRange().getValues();
      for (let i = 1; i < values.length; i++) {
        if (String(values[i][0]).trim() === String(data.orderId).trim()) {
          sheet.getRange(i + 1, 9).setValue(data.totalPrice); // I
          sheet.getRange(i + 1, 10).setValue(data.itemsSummary); // J
          return responseJson({ status: "success" });
        }
      }
      return responseJson({ status: "not_found" });
    }

    // 4. Ambil Semua Status Pesanan (untuk sinkron ke aplikasi)
    if (data.action === "getOrderStatuses") {
      const sheet = getPesananSheet_(ss);
      const values = sheet.getDataRange().getValues();
      const orders = [];
      for (let i = 1; i < values.length; i++) {
        const id = String(values[i][0]).trim();
        if (!id) continue;
        orders.push({ id: id, status: String(values[i][7]).trim() }); // H
      }
      return responseJson({ status: "ok", orders: orders });
    }

    // 5. Simpan Pengguna Baru
    if (data.action === "saveUser") {
      const sheet = ss.getSheetByName("User");
      const headers = sheet
        .getRange(1, 1, 1, sheet.getLastColumn())
        .getValues()[0];
      const u = data.user;
      const values = {
        "nama lengkap": u.name,
        nama: u.name,
        username: u.name,
        "nomor telepon": u.phone,
        "no telepon": u.phone,
        telepon: u.phone,
        phone: u.phone,
        email: u.email,
        password: u.password || "-"
      };

      const row = headers.map(function (header) {
        const key = String(header).toLowerCase().trim();
        return Object.prototype.hasOwnProperty.call(values, key)
          ? values[key]
          : "";
      });

      sheet.appendRow(row);
      return responseJson({ status: "success" });
    }

    // 6. Login
    if (data.action === "login") {
      const sheet = ss.getSheetByName("User");
      const values = sheet.getDataRange().getValues();
      if (values.length < 2) return responseJson({ status: "error" });

      const headers = values[0].map(function (header) {
        return String(header).toLowerCase().trim();
      });

      const col = function (names) {
        for (let i = 0; i < headers.length; i++) {
          for (let j = 0; j < names.length; j++) {
            if (headers[i].indexOf(names[j]) !== -1) return i;
          }
        }
        return -1;
      };

      const nameCol = col(["nama", "name", "username"]);
      const emailCol = col(["email"]);
      const phoneCol = col(["telepon", "phone", "hp", "whatsapp"]);
      const passCol = col(["password", "sandi"]);

      if (passCol === -1) {
        return responseJson({
          status: "error",
          message: "Kolom password tidak ditemukan"
        });
      }

      const q = String(data.username).trim().toLowerCase();
      for (let i = 1; i < values.length; i++) {
        const name = nameCol === -1 ? "" : String(values[i][nameCol]).trim();
        const email = emailCol === -1 ? "" : String(values[i][emailCol]).trim();
        const match = name.toLowerCase() === q || email.toLowerCase() === q;

        if (match && String(values[i][passCol]) === String(data.password)) {
          return responseJson({
            status: "ok",
            user: {
              name: name,
              email: email,
              phone: phoneCol === -1 ? "" : String(values[i][phoneCol])
            }
          });
        }
      }

      return responseJson({ status: "error" });
    }

    return responseJson({ status: "unknown_action" });
  } catch (err) {
    return responseJson({ status: "error", message: err.toString() });
  }
}

function responseJson(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(
    ContentService.MimeType.JSON
  );
}
