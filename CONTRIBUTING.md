# Contributing

Thanks for your interest in improving the **Generative AI Seminar Projects** repo!

## How to Contribute

1. **Fork & Clone**

   ```bash
   git clone https://github.com/Developer-Linus/generative_ai_ouk.git
   cd generative_ai_ouk
   ```
2. **Create a Branch**

   ```bash
   git checkout -b feature/my-change
   ```
3. **Make Changes**

   * Add Jac code in the correct `week-XX/src/` folder
   * Update Byllm routes if needed
   * Document updates in that week’s `README.md`
4. **Test Locally**

   ```bash
   byllm serve app.byllm
   curl http://localhost:8000/my-endpoint
   ```
5. **Commit & Push**

   ```bash
   git add .
   git commit -m "Add: short description"
   git push origin feature/my-change
   ```
6. **Open a Pull Request** on GitHub

## Guidelines

* Keep Jac code clean & modular
* Don’t break existing Byllm routes
* Always update documentation for new features
* Be respectful and collaborative 🙌

