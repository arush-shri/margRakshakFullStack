const express = require("express");
const userRouter = express.Router();
const userController = require('../controllers/userController')

userRouter.get('/createUser/:email', async (req,res) => {
    const database = req.app.locals.database;
    const email = req.params.email;
    const result = await userController.initiateSignup(database, email);
    if(result === true){
        res.status(200).send(result);
    }
    else{
        res.status(402).send(result);
    }
});

userRouter.get('/userExists/:email', async (req,res) => {
    const database = req.app.locals.database;
    const email = req.params.email;
    const result = await userController.checkExistence(database, email);
    if(result === true){
        res.status(200).send(result);
    }
    else{
        res.status(402).send(result);
    }
});

userRouter.post('/updateHomeLocation/:email', async (req,res) => {
    const database = req.app.locals.database;
    const email = req.params.email;
    const result = await userController.setHomeLocation(database, email, req.body.latitude, req.body.longitude);
    if(result === true){
        res.status(200).send(result);
    }
    else{
        res.status(402).send(result);
    }
});

userRouter.get('/getHomeLocation/:email', async (req, res) => {
    const database = req.app.locals.database;
    const email = req.params.email;
    console.log(email)
    const result = await userController.getHomeLocation(database, email);
    if(result){
        res.status(200).send(result)
    }
});

module.exports = userRouter;