const puppeteer = require("puppeteer-extra");
const pluginStealth = require("puppeteer-extra-plugin-stealth");

const FormData = require("form-data");
const fs = require("fs");
const { default: axios } = require("axios");

puppeteer.use(pluginStealth());

const express = require("express");

const app = express();

app.get("/", async (req, res) => {
  const result = await scrap();

  res.json({ message: result });
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});

const scrap = async () => {
  try {
    const browser = await puppeteer.launch({
      executablePath: "google-chrome-stable",
      args: [
        "--window-size=1920,1080",
        "--no-sandbox",
        "--disable-web-security",
        "--disable-setuid-sandbox",
        "--disable-gpu",
        // "--enable-gpu",
        "--disable-dev-shm-usage", // Added to improve compatibility
        // "--single-process", // Might improve stability in Lambda's environment
        // "--user-data-dir=/tmp/chrome-user-data",
      ],
      headless: true,
    });

    let page = await browser.newPage();

    await page.goto("https://www.voeazul.com.br/", {
      waitUntil: "networkidle2",
    });

    await sendScreenshotError(page, "teste");
    console.log("browser is up");

    await browser.close();
    console.log("browser is closed");

    return "all good";
  } catch (error) {
    console.log("error", error);
    return JSON.stringify(error);
  }
};

const sendScreenshotError = async (page, message) => {
  const screenshotPath = `/tmp/azul.png`;
  await page.screenshot({ path: screenshotPath });

  const formData = new FormData();
  formData.append("file", fs.createReadStream(screenshotPath));
  formData.append("payload_json", JSON.stringify({ content: message }));

  await axios.post(
    "https://discord.com/api/webhooks/1203057888587939881/mHpbJhrsMe9lYUb3rgKJamd8o4MKIflqNzq6mEslxnQTZoQhiuwYeMN8ShKM4qW5t2Md",
    formData,
    {
      headers: {
        ...formData.getHeaders(),
      },
    }
  );
};
