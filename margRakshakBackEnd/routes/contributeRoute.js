const express = require("express");
const contributionRoute = express.Router();
const contributionController = require('../controllers/contributionController')

contributionRoute.post('/makeContribution', async (req,res) => {
    const database = req.app.locals.database;
    const result = await contributionController.MakeContribution(database, req.body.collectionName, req.body.latitude,
            req.body.longitude, req.body.name);
    if(result === true){
        res.status(200).send(true);
    }
    else{
        res.status(500).send(false);
    }
});

contributionRoute.post('/getOtherName', async (req,res) => {
    const database = req.app.locals.database;
    const result = await contributionController.getOtherName(database, req.body.latitude, req.body.longitude);
    if(result){
        res.status(200).send(result);
    }
    else{
        res.status(404).send(false);
    }
});

module.exports = contributionRoute;