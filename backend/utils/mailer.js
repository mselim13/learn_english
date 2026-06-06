const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.MAIL_HOST,
  port: parseInt(process.env.MAIL_PORT || '587', 10),
  secure: process.env.MAIL_PORT === '465', // true = SSL, false = TLS
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});

/**
 * Kullanıcıya parola sıfırlama OTP'si gönderir.
 * @param {string} to   - Alıcı e-posta adresi
 * @param {string} otp  - 6 haneli kod
 */
async function sendResetOtp(to, otp) {
  const from =
    process.env.MAIL_FROM || `"Learn English" <${process.env.MAIL_USER}>`;

  await transporter.sendMail({
    from,
    to,
    subject: 'Parola Sıfırlama Kodun',
    html: `
      <!DOCTYPE html>
      <html lang="tr">
      <body style="margin:0;padding:0;background:#f5f0fa;font-family:Arial,sans-serif;">
        <table width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <td align="center" style="padding:40px 16px;">
              <table width="480" cellpadding="0" cellspacing="0"
                     style="background:#ffffff;border-radius:16px;overflow:hidden;
                            box-shadow:0 4px 24px rgba(74,20,140,0.08);">
                <!-- Header -->
                <tr>
                  <td style="background:linear-gradient(135deg,#9C6ADE,#7A3EC8);
                              padding:32px;text-align:center;">
                    <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:700;">
                      Parola Sıfırlama
                    </h1>
                  </td>
                </tr>
                <!-- Body -->
                <tr>
                  <td style="padding:32px;">
                    <p style="margin:0 0 16px;color:#444;font-size:15px;line-height:1.5;">
                      Parola sıfırlama talebinde bulundun. Uygulamadaki ekrana
                      aşağıdaki <strong>6 haneli kodu</strong> gir:
                    </p>
                    <!-- OTP Box -->
                    <div style="background:#f5f0fa;border-radius:12px;padding:28px;
                                text-align:center;margin:24px 0;">
                      <span style="font-size:42px;font-weight:800;letter-spacing:10px;
                                   color:#4A148C;">${otp}</span>
                    </div>
                    <p style="margin:0 0 8px;color:#888;font-size:13px;">
                      ⏱ Bu kod <strong>15 dakika</strong> geçerlidir.
                    </p>
                    <p style="margin:0;color:#888;font-size:13px;">
                      Eğer bu talebi sen yapmadıysan bu e-postayı yoksay.
                    </p>
                  </td>
                </tr>
                <!-- Footer -->
                <tr>
                  <td style="background:#faf8ff;padding:16px 32px;text-align:center;
                              border-top:1px solid #ede8f8;">
                    <p style="margin:0;color:#aaa;font-size:11px;">
                      Learn English — LinguaAI
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    `,
  });
}

module.exports = { sendResetOtp };
