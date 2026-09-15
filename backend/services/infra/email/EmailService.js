const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT),
    secure: process.env.SMTP_SECURE === "true",
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD,
    },
});

const EmailService = {

    async sendVerificationCode(email, code) {

        console.log("here");

        await transporter.sendMail({
            from: process.env.SMTP_FROM,
            to: email,
            subject: "Verify your email address",

            text:
                `Your verification code is ${code}. ` +
                `It expires in 10 minutes.`,

            html: `
                <div>
                    <h2>Verify your email</h2>

                    <p>
                        Enter the following code to verify
                        your email address:
                    </p>

                    <h1>${code}</h1>

                    <p>
                        This code expires in 10 minutes.
                    </p>
                </div>
            `,
        });
    },
};

module.exports = EmailService;