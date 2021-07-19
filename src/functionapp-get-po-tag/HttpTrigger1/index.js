module.exports = async function (context, req) {

    const rgname = req.query.rgname;
    const subscriptionid = req.query.subscriptionid;

    const { DefaultAzureCredential } = require("@azure/identity");
    const credentials = new DefaultAzureCredential();

    const { ResourceManagementClient } = require("@azure/arm-resources");
    const resourceManagement = new ResourceManagementClient(credentials, subscriptionid);
    
    const result = await resourceManagement.resourceGroups.get(rgname)
    context.res = {
        status : 200, 
        body : result.tags.ProjectOwner
    }
}

