import http from "k6/http";
import { sleep } from "k6";

export const options = {
  vus: 1000,
  duration: "3m",

  thresholds: {
    http_req_duration: ["p(95)<1000"],
    http_req_failed: ["rate<0.01"],
  },
};

const BASE = __ENV.BASE || "https://example.com";

export default function () {
  http.get(`${BASE}/`);
  http.get(`${BASE}/about/`);
  http.get(`${BASE}/projects/`);
  http.get(`${BASE}/resources/`);
  http.get(`${BASE}/services/`);
  http.get(`${BASE}/static/main-BVK3UCiJ.css`);
  http.get(`${BASE}/static/main-Di0wIRw8.js`);
  sleep(1 + Math.random() * 4); // critical: prevents generator meltdown
}
