module.exports = async function (context, req) {
    context.log('HttpTrigger2 function started processing a request.');
   
    const name = (req.query.name || (req.body && req.body.name));
    //await client.set('name', name);
    const redisName = await context.redisClient.get('name');
    const responseMessage = redisName
        ? "Hello, " + redisName + ". This HTTP triggered function executed successfully."
        : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";

    context.log('HttpTrigger2 function ended processing a request.');
    context.res = {
        // status: 200, /* Defaults to 200 */
        body: responseMessage
    };
};
