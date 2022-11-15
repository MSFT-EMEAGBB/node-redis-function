const { registerHook } = require("@azure/functions-core");
const { createClient } = require("redis");

console.log("Hello world");
registerHook("appStart", async (context) => {
  const cacheHostName = process.env.REDIS_HOST;
  const cachePassword = process.env.REDIS_KEY;
  const client = createClient({
    // rediss for TLS
    url: "rediss://" + cacheHostName + ":6380",
    password: cachePassword,
  });
  console.log("Redis client connecting");
  await client.connect();
  context.appHookData.redisClient = client;
});

registerHook("preInvocation", (context) => {
  context.invocationContext.redisClient = context.appHookData.redisClient;
});