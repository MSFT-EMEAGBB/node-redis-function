import { createClient } from 'redis';

const cacheHostName = process.env.REDIS_HOST;
const cachePassword = process.env.REDIS_KEY;
const client = createClient({
    // rediss for TLS
    url: "rediss://" + cacheHostName + ":6380",
    password: cachePassword,
});

console.log("Redis client connecting");
await client.connect();
console.log("Redis client connected");

export const redisClient = client;