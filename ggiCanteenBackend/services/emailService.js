const nodemailer = require('nodemailer');

// ─────────────────────────────────────────────
// Create reusable transporter (lazy init)
// ─────────────────────────────────────────────
let _transporter = null;

function getTransporter() {
  if (!_transporter) {
    const emailUser = (process.env.EMAIL_USER || 'chandni5developer@gmail.com').trim();
    const emailPass = (process.env.EMAIL_PASSWORD || 'kmyujlkeywhedfxn').replace(/\s+/g, '');
    const emailHost = (process.env.EMAIL_HOST || 'smtp.gmail.com').trim();
    const emailPort = parseInt(process.env.EMAIL_PORT || '465');

    // Automatically use Gmail service for gmail domains or host to prevent port 587 STARTTLS ECONNRESET / timeout
    const isGmail = emailHost.includes('gmail') || emailUser.endsWith('@gmail.com');

    if (isGmail) {
      _transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: emailUser,
          pass: emailPass,
        },
        connectionTimeout: 15000,
        greetingTimeout: 10000,
        socketTimeout: 20000,
      });
    } else {
      _transporter = nodemailer.createTransport({
        host: emailHost,
        port: emailPort,
        secure: emailPort === 465,
        auth: {
          user: emailUser,
          pass: emailPass,
        },
        connectionTimeout: 15000,
        greetingTimeout: 10000,
        socketTimeout: 20000,
      });
    }
  }
  return _transporter;
}

// ─────────────────────────────────────────────
// Send OTP Email — Professional HTML Template
// ─────────────────────────────────────────────
async function sendOTPEmail(email, otp) {
  const emailUser = (process.env.EMAIL_USER || 'chandni5developer@gmail.com').trim();
  const from = process.env.EMAIL_FROM || `"Hunger Zone" <${emailUser}>`;

  const htmlBody = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Hunger Zone OTP</title>
</head>
<body style="margin:0;padding:0;background:#f4f4f4;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f4;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="480" cellpadding="0" cellspacing="0"
               style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
          <!-- Header -->
          <tr>
            <td align="center" style="background:linear-gradient(135deg,#FF4B4B,#FF6B6B);padding:36px 40px;">
              <p style="margin:0;font-size:32px;">🍽️</p>
              <h1 style="margin:12px 0 0;color:#ffffff;font-size:26px;font-weight:700;letter-spacing:1px;">
                Hunger Zone
              </h1>
              <p style="margin:6px 0 0;color:rgba(255,255,255,0.85);font-size:14px;">
                Campus Canteen & Food Ordering
              </p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:40px;">
              <p style="margin:0 0 16px;color:#333;font-size:16px;">Hello,</p>
              <p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">
                Your Hunger Zone verification code is:
              </p>
              <!-- OTP Box -->
              <div style="text-align:center;margin:0 0 32px;">
                <div style="display:inline-block;background:#FFF5F5;border:2px solid #FF6B6B;
                            border-radius:12px;padding:20px 48px;">
                  <span style="font-size:42px;font-weight:900;letter-spacing:16px;color:#FF4B4B;
                               font-family:'Courier New',monospace;">
                    ${otp}
                  </span>
                </div>
              </div>
              <p style="margin:0 0 12px;color:#888;font-size:13px;text-align:center;">
                ⏱️ This OTP is valid for <strong>5 minutes</strong>.
              </p>
              <hr style="border:none;border-top:1px solid #eee;margin:28px 0;"/>
              <p style="margin:0;color:#aaa;font-size:12px;line-height:1.6;">
                If you did not request this OTP, please ignore this email.
                Do not share this code with anyone.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td align="center"
                style="background:#fafafa;padding:20px;border-top:1px solid #eee;">
              <p style="margin:0;color:#bbb;font-size:11px;">
                © 2026 Hunger Zone · GGI Campus, Amritsar
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `;

  const errors = [];
  const senderEmail = (process.env.BREVO_SENDER_EMAIL || emailUser).trim();

  // 1. Brevo HTTPS API (Port 443 — Bypasses cloud SMTP port blocking, sends to ANY recipient)
  if (process.env.BREVO_API_KEY) {
    try {
      console.log(`[EMAIL] Sending via Brevo HTTPS API (port 443) from ${senderEmail}...`);
      const res = await fetch('https://api.brevo.com/v3/smtp/email', {
        method: 'POST',
        headers: {
          'api-key': process.env.BREVO_API_KEY.trim(),
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          sender: {
            name: process.env.EMAIL_SENDER_NAME || 'Hunger Zone',
            email: senderEmail,
          },
          to: [{ email }],
          subject: 'Hunger Zone — Your Verification OTP',
          htmlContent: htmlBody,
          textContent: `Your Hunger Zone verification OTP is: ${otp}\n\nThis OTP is valid for 5 minutes.\n\nRegards,\nHunger Zone`,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.message || JSON.stringify(data));
      }

      console.log(`[EMAIL] ✅ OTP sent successfully via Brevo to ${email} — MessageId: ${data.messageId}`);
      return { messageId: data.messageId, provider: 'brevo' };
    } catch (brevoErr) {
      console.error(`[EMAIL WARN] Brevo failed: ${brevoErr.message}. Checking next provider...`);
      errors.push(`Brevo: ${brevoErr.message}`);
    }
  }

  // 2. Resend HTTPS API (Port 443 — Fallback if configured)
  if (process.env.RESEND_API_KEY) {
    try {
      console.log('[EMAIL] Sending via Resend HTTPS API (port 443)...');
      const res = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${process.env.RESEND_API_KEY.trim()}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: process.env.RESEND_FROM || 'Hunger Zone <onboarding@resend.dev>',
          to: [email],
          subject: 'Hunger Zone — Your Verification OTP',
          html: htmlBody,
          text: `Your Hunger Zone verification OTP is: ${otp}\n\nThis OTP is valid for 5 minutes.\n\nRegards,\nHunger Zone`,
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        throw new Error(data.message || JSON.stringify(data));
      }

      console.log(`[EMAIL] ✅ OTP sent successfully via Resend to ${email} — ID: ${data.id}`);
      return { messageId: data.id, provider: 'resend' };
    } catch (resendErr) {
      console.error(`[EMAIL WARN] Resend failed: ${resendErr.message}. Checking next provider...`);
      errors.push(`Resend: ${resendErr.message}`);
    }
  }

  // 3. Nodemailer SMTP (Local development, VPS, or cloud hosts with open SMTP ports)
  try {
    console.log('[EMAIL] Attempting delivery via Nodemailer SMTP...');
    const mailOptions = {
      from,
      to: email,
      subject: 'Hunger Zone — Your Verification OTP',
      text: `Your Hunger Zone verification OTP is: ${otp}\n\nThis OTP is valid for 5 minutes.\n\nIf you did not request this OTP, please ignore this email.\n\nRegards,\nHunger Zone`,
      html: htmlBody,
    };

    const transporter = getTransporter();
    const info = await transporter.sendMail(mailOptions);
    console.log(`[EMAIL] ✅ OTP sent successfully via SMTP to ${email} — MessageId: ${info.messageId}`);
    return { messageId: info.messageId, provider: 'smtp' };
  } catch (smtpErr) {
    console.error(`[EMAIL WARN] SMTP failed: ${smtpErr.message}`);
    errors.push(`SMTP: ${smtpErr.message}`);
  }

  // If all providers failed
  const summaryError = errors.length > 0
    ? errors.join(' | ')
    : 'No email provider configured. Please configure BREVO_API_KEY or EMAIL_PASSWORD.';

  console.error(`[EMAIL ERROR] All email providers failed to send OTP to ${email}: ${summaryError}`);
  console.log(`[DEV OTP LOG] Verification code for ${email} is: ${otp}`);

  throw new Error(`Failed to send email (${summaryError})`);
}

module.exports = { sendOTPEmail, getTransporter };
