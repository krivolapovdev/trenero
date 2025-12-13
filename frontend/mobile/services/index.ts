import axios from 'axios';

export const api = axios.create({
  baseURL: 'http://10.0.2.2:8080',
  timeout: 10_000,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json'
  }
});
