# Voćara: paket za instalaciju

Ovaj paket sadrži aplikaciju Voćara spremnu za tri načina instalacije.

```
vocara-app/
├── www/                  ← aplikacija (radi i kao PWA na sajtu)
│   ├── index.html
│   ├── manifest.json     ← naziv, ikonica i boje za instalaciju na telefon
│   ├── sw.js             ← rad bez interneta
│   ├── qrcode.min.js     ← biblioteka za IPS QR kod (MIT licenca)
│   └── icons/
├── android/              ← Android projekat (otvara se u Android Studiju)
├── ios/                  ← iOS projekat (otvara se u Xcode-u na Mac računaru)
├── .github/workflows/    ← automatsko pravljenje Android aplikacije na GitHubu
├── store/                ← ikonica za Google Play (512) i App Store (1024)
├── firebase.json         ← podešavanje za Firebase Hosting (Google)
├── capacitor.config.json ← ID aplikacije: rs.vocara.app
└── package.json
```

> **Važno:** ovo je prototip. Podaci se čuvaju samo na telefonu korisnika, a brojevi računa u IPS QR kodovima su izmišljeni (DEMO). Pre objave u prodavnicama aplikaciju treba povezati sa serverom (Supabase), prijavom korisnika i pravim računima.

---

## 1. Najbrže: instalacija sa sajta (PWA), bez prodavnica

Korisnik otvori sajt i doda aplikaciju na početni ekran. Dobija ikonicu, celoekranski prikaz i rad bez interneta.

1. Postavite sadržaj foldera `www/` na bilo koji hosting sa **HTTPS**-om, na primer:
   - **Netlify Drop** (app.netlify.com/drop): prevucite folder `www`, dobijate adresu za minut, besplatno.
   - **GitHub Pages**, **Cloudflare Pages** ili hosting koji već imate.
2. Na telefonu otvorite adresu:
   - **Android (Chrome):** meni ⋮ → **Instaliraj aplikaciju** / **Dodaj na početni ekran**
   - **iPhone (Safari):** dugme Deli → **Dodaj na početni ekran**

## 1a. Web verzija na Google serveru (Firebase Hosting)

1. Otvorite https://console.firebase.google.com i kliknite **Create a project** (npr. `vocara`). Zapišite **Project ID**.
2. Project ID `vocara-voce` je već upisan u `.firebaserc`. Na Windows računaru samo dvaput kliknite **POSTAVI-NA-FIREBASE.bat** i pratite poruke. Ili ručno:
3. Na računaru sa instaliranim Node.js:

```bash
npm install -g firebase-tools
firebase login
cd vocara-app
firebase deploy --only hosting
```

Dobijate adresu oblika `https://vocara.web.app`, koja se otvara na svakom telefonu i može da se instalira kao aplikacija. Kasnije u Firebase konzoli možete povezati i svoj domen (Hosting → Add custom domain).

## 2. Android aplikacija (APK i Google Play)

Potrebno: računar sa [Android Studiom](https://developer.android.com/studio) i [Node.js](https://nodejs.org) 20 ili noviji.

```bash
cd vocara-app
npm install          # preuzima Capacitor
npx cap sync android # kopira www/ u Android projekat
npx cap open android # otvara Android Studio
```

U Android Studiju:
- **Probna verzija na telefonu:** povežite telefon USB kablom (uključite „USB debugging“) i kliknite ▶ Run.
- **APK za deljenje:** Build → Build Bundle(s) / APK(s) → Build APK(s).
- **Za Google Play:** Build → Generate Signed Bundle / APK → **Android App Bundle (.aab)**. Napravite ključ za potpisivanje i **sačuvajte ga na sigurno**: bez njega ne možete objavljivati nove verzije.

Objava: napravite nalog na play.google.com/console (jednokratna naknada), popunite opis, snimke ekrana i politiku privatnosti, pa otpremite `.aab`.

## 2a. Android aplikacija preko GitHuba (bez Android Studija)

GitHub sam napravi aplikaciju na svojim serverima. Uputstvo je u `.github/workflows/android.yml`.

**1. Postavite projekat na GitHub**
- Napravite nalog na github.com i novi **privatni** repozitorijum, na primer `vocara`.
- Otpremite sadržaj foldera `vocara-app` (bez `node_modules`): Add file → Upload files, ili preko GitHub Desktop aplikacije. Folder `.github` mora da bude otpremljen.

**2. Preuzmite APK za probu**
- Otvorite karticu **Actions** → *Android build*. Pokreće se sam posle otpremanja (ili kliknite **Run workflow**).
- Posle 5–10 minuta, na dnu stranice pod **Artifacts** preuzmite `vocara-apk-…` i instalirajte APK na Android telefon.

**3. Za Google Play: potpisan AAB**
Napravite ključ za potpis (jednom, na računaru sa instaliranom Javom):

```bash
keytool -genkeypair -v -keystore vocara-release.jks -alias vocara \
  -keyalg RSA -keysize 2048 -validity 10000
base64 -w0 vocara-release.jks > keystore.txt      # Windows: certutil -encode vocara-release.jks keystore.txt
```

Na GitHubu: Settings → Secrets and variables → Actions → **New repository secret**, pa dodajte četiri tajne:

| Naziv | Vrednost |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | ceo sadržaj `keystore.txt` (kod Windows-a bez prvog i poslednjeg reda) |
| `ANDROID_KEYSTORE_PASSWORD` | lozinka ključa |
| `ANDROID_KEY_ALIAS` | `vocara` |
| `ANDROID_KEY_PASSWORD` | lozinka ključa |

Sledeće pokretanje daje i `vocara-google-play-…` sa `.aab` datotekom koju otpremate u Google Play Console. Broj verzije raste sam pri svakom pokretanju.

> Ključ `vocara-release.jks` i lozinku čuvajte van GitHuba, na sigurnom mestu. Nikad ga ne otpremajte u repozitorijum (`.gitignore` to već sprečava).

## 3. iPhone aplikacija (App Store)

Potrebno: **Mac** sa Xcode-om i Apple Developer nalog (godišnja članarina).

```bash
npm install
npx cap sync ios
npx cap open ios
```

U Xcode-u izaberite svoj tim (Signing & Capabilities), pa Product → Archive → Distribute App.

---

## Posle svake izmene aplikacije

Menjate samo fajlove u `www/`, zatim:

```bash
npx cap sync
```

Za PWA ponovo postavite `www/` na hosting i u `www/sw.js` povećajte broj verzije (`vocara-v1` → `vocara-v2`), da bi telefoni preuzeli novu verziju.

## Pre objave u prodavnicama

- [ ] Povezati server (Supabase): nalozi, grupe, čet u realnom vremenu, rezervacije
- [ ] Prijava telefonom (SMS kod)
- [ ] Obaveštenja (Firebase Cloud Messaging): nova poruka, stigla ponuda, farmer stiže sutra
- [ ] Pravi računi gazdinstava i firme u IPS QR kodu, potvrda uplate preko banke
- [ ] Politika privatnosti i uslovi korišćenja (Zakon o zaštiti podataka o ličnosti)
- [ ] Prijava i blokiranje korisnika u četu (prodavnice to zahtevaju za aplikacije sa četom)
- [ ] Brisanje naloga iz aplikacije (zahtev Google Play-a i App Store-a)
- [ ] Naplata tezge preko fakture ili sajta, ne kupovinom u aplikaciji
