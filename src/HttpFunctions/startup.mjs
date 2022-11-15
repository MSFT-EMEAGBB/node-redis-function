import { registerHook } from '@azure/functions-core'
import {redisClient } from '../redisClient.mjs';

registerHook('appStart', async (context) => { 
    await redisClient.ping();
});