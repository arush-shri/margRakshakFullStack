async function MakeContribution (database, collectionName, latitude, longitude, name) {
    const check1 = await database.collection("AccidentArea").findOne({'location.coordinates': [ longitude, latitude ]});
    const check2 = await database.collection("RailwayCross").findOne({'location.coordinates': [ longitude, latitude ]});
    const check3 = await database.collection("ForestRoad").findOne({'location.coordinates': [ longitude, latitude ]});
    const check4 = await database.collection("GhatRegion").findOne({'location.coordinates': [ longitude, latitude ]});
    const check5 = await database.collection("OtherRegion").findOne({'location.coordinates': [ longitude, latitude ]});
    if(collectionName === "OtherRegion"){
        setOtherName(database, latitude, longitude, name);
    }
    if(!(check1 && check2 && check3 && check4 && check5)){
        const collection = database.collection(collectionName);
        const query = {
            location: {
                "type": 'Point',
                coordinates: [parseFloat(longitude, 10), parseFloat(latitude, 10)]
            }
        };
        const result = await collection.insertOne(query);
        if(result.acknowledged === true){
            console.log(collectionName);
            console.log(query);
            return true;
        }
        else{
            return false;
        }
    }
}

async function setOtherName(database, latitude, longitude, name){
    const collectionName = database.collection("OtherName");
    const query = {
        "latitude": latitude,
        "longitude": longitude,
        "areaName": name
    };
    const result = await collectionName.insertOne(query);
    if(result.acknowledged === true){
        return true;
    }
    return false;
}

async function getOtherName(database, latitude, longitude){
    const collectionName = database.collection("OtherName");
    const query = {
        "latitude": latitude,
        "longitude": longitude,
    };
    const result = await collectionName.findOne(query);
    if(result){
        return result;
    }
    else{
        return false;
    }
}

module.exports = { MakeContribution, getOtherName };