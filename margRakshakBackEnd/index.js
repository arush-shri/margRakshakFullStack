const express = require("express");
const application = express();
const contributionRoute = require('./routes/contributeRoute')
const navigationRoute = require('./routes/navRoute')
const userRoute = require('./routes/userRoute')
const database = require('./controllers/dbConnector') 

const cors = require("cors");

application.use(cors());
application.use(express.json());
application.use("/contribute", contributionRoute);
application.use("/user", userRoute);
application.use("/navigation", navigationRoute);

application.get('/', (req,res) => {
    res.status(200).send("Hello! Welcome to marg rakshak");
});

database.initDb(
    function(err){
        application.listen(4000, () => {
            if(err){
                console.log(err)
                throw err;
            }
            application.locals.database = database.getDb();
            console.log("Server started at port 4000");
        });
    }
);