# Robot Framework API Testing

[![Robot Framework Tests](https://github.com/ctrlfaith/robot-framework-api-testing/actions/workflows/robot-tests.yml/badge.svg)](https://github.com/ctrlfaith/robot-framework-api-testing/actions/workflows/robot-tests.yml)

API test suite for [Restful Booker](https://restful-booker.herokuapp.com) built with Robot Framework.  
This project is a continuation of [qa-portfolio-api-testing](https://github.com/ctrlfaith/qa-portfolio-api-testing) which used Postman — rebuilt to demonstrate how the same test coverage can be achieved with a code-based framework.

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Robot Framework 7.4.2 | Test framework |
| RequestsLibrary | HTTP requests |
| Collections Library | Dictionary assertions |
| Python 3.13 | Runtime |
| GitHub Actions | CI/CD |

---

## Folder Structure

```
robot-framework-api-testing/
├── resources/
│   ├── keywords.resource      # Reusable keywords
│   └── variables.resource     # BASE_URL, credentials
├── tests/
│   ├── 01_auth_test.robot     # Authentication tests
│   ├── 02_booking_crud.robot  # CRUD tests
│   └── 03_edge_cases.robot    # Edge cases & security
├── .github/
│   └── workflows/
│       └── robot-tests.yml    # GitHub Actions CI/CD
└── results/                   # HTML reports (git-ignored)
```

---

## How to Run

**Install dependencies**
```bash
pip install robotframework robotframework-requests robotframework-jsonlibrary
```

**Run all tests**
```bash
robot --outputdir results tests/
```

**Run by tag**
```bash
robot --include smoke --outputdir results tests/
robot --include negative --outputdir results tests/
robot --include security --outputdir results tests/
robot --include bug --outputdir results tests/
```

**View report**
```bash
start results/report.html
```

---

## Test Coverage

| File | Tests | Tags |
|---|---|---|
| 01_auth_test.robot | 2 | smoke, negative |
| 02_booking_crud.robot | 7 | smoke, negative |
| 03_edge_cases.robot | 13 | smoke, negative, security, bug |
| **Total** | **22** | |

### Endpoints Covered

| Method | Endpoint | Test |
|---|---|---|
| GET | /ping | Health check |
| POST | /auth | Get token, invalid credentials |
| GET | /booking | List all bookings |
| GET | /booking/{id} | Get single booking + field type validation |
| POST | /booking | Create booking |
| PUT | /booking/{id} | Full update |
| PATCH | /booking/{id} | Partial update |
| DELETE | /booking/{id} | Delete with/without token |

---

## Bugs Found

| # | Test Case | Expected | Actual | Severity |
|---|---|---|---|---|
| 1 | Missing required fields | 400 Bad Request | 500 Internal Server Error | High |
| 2 | Invalid date format | 400 Bad Request | 200 OK — stores `0NaN-aN-aN` | High |
| 3 | Negative price | 400 Bad Request | 200 OK — accepts `-999` | Critical |
| 4 | Checkout before checkin | 400 Bad Request | 200 OK — accepts impossible date range | High |
| 5 | XSS in firstname | 400 or sanitized | 200 OK — stores raw `<script>` tag | Critical |

---

## Postman vs Robot Framework

Both projects test the same Restful Booker API with identical coverage (22 test cases). Here is how the two approaches compare:

| Aspect | Postman | Robot Framework |
|---|---|---|
| **Setup** | GUI — no installation needed | CLI — requires Python + pip install |
| **Test syntax** | JavaScript (`pm.test`) | Keyword-driven (readable English) |
| **Reusability** | Limited — copy-paste across requests | High — custom keywords in `.resource` files |
| **Version control** | JSON export only | Native code — full Git diff |
| **CI/CD** | Newman CLI required | Built-in `robot` command |
| **Reporting** | Postman cloud / Newman HTML | Built-in HTML + XML report |
| **Data-driven** | Collection Runner + CSV | Native `[Template]` + CSV |
| **Readability** | Moderate — JavaScript assertions | High — plain English keywords |
| **Learning curve** | Low — GUI-friendly | Medium — requires Python knowledge |
| **Best for** | Quick exploration, manual testing | Regression suite, CI/CD pipeline |

### When to use which

**Postman** — exploring a new API, quick one-off testing, sharing requests with teammates who don't code.

**Robot Framework** — building a maintainable regression suite, integrating into CI/CD, writing tests that non-developers can read and understand.

---

## 👨‍💻 Author
**Name:** Phuriphatthanachai Rattanatham  
**GitHub:** [@ctrlfaith](https://github.com/ctrlfaith)
