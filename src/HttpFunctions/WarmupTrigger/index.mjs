import {redisClient} from '../redisClient.mjs';

console.log('Warmup trigger function initialized.')

export default async function (context, warmupContext) {
    await redisClient.ping();
};