const express = require("express");
const navigating = express.Router();
const navigatingController = require('../controllers/navigatingController');
const { ObjectId } = require("mongodb");

let myLocation;
let UserPositionID;

navigating.post('/myLocation', async (req,res) => {
    const database = req.app.locals.database;
    console.log(req.body);
    myLocation = {
        "latitude": req.body.latitude,
        "longitude": req.body.longitude
    };
    const result = await navigatingController.SetMyLocation(database, req.body.email, req.body.latitude, req.body.longitude);
    const objectId = await navigatingController.SetUserLocation(database, req.body.latitude, req.body.longitude, req.body.objectId);
    if(objectId){
        UserPositionID = objectId;
    }
    if(result){
        UserPositionID = objectId;
        res.status(200).send(objectId);
    }
    else{
        res.status(500).send(false);
    }
});

navigating.get('/getDangers/:distance', async (req,res) => {
    const database = req.app.locals.database;
    console.log(req.params.distance);
    const result = await navigatingController.GetDangers(database, myLocation, req.params.distance);
    try{
        if(UserPositionID){
            
            const obj = new ObjectId(JSON.parse(UserPositionID));
            const indexToRemove = result.UserPosition.findIndex(item => item._id.toString() === obj.toString());
            if (indexToRemove !== -1) {
                result.UserPosition.splice(indexToRemove, 1);
            }
        }
    }
    catch(error){
        console.log(error);
    }
    console.log(result);
    res.status(200).send(result);
});

navigating.get('/getUserLocation/:email', async (req,res) => {
    const database = req.app.locals.database;
    const email = req.params.email;
    console.log(email);
    const result = navigatingController.SharedUserLocation(database, email);
    res.redirect(`https://www.google.com/maps?q=${result.latitude},${result.longitude}`);
})

module.exports = navigating;