
/*  1  */ 

/*  user collection  */
{
  _id (ObjectId)
  name (string)
  email (string)
  password (string)
  phone_number (string)
  date_of_birth (date)
  address (string)
  profile_creation_date (date)
  working_status (string)
  bios (string)
  hobbies (array)
  following (array)
  followers (array)
}

/*  post collection  */
{
  _id (ObjectId)
  user_id (ObjectId)
  content (string)
  likes (array)
  comments (array)
  created_at (date)
}


/* Modifications of the "comments" atrribute of the "post" collection */
({   
  "comments": [
    { 
      "text": "Noice", 
      "user_id": ObjectId("64100a89d87392106fab76f5")
    },
    { 
      "text": "Luv it!", 
      "user_id": ObjectId("64100a89d87392106fab76f6")
    }
  ]
})


/*  2(a)  */
db.user.insertOne({
  "name": "DAM",
  "email": "DAM@example.com",
  "password": "12345678",
})

/*  2(b)  &  2(c)  */
db.user.insertOne({
  "name": "MAK Shelby",
  "email": "mak_shelby@example.com",
  "password": "12345678",
  "phone_number": "01838292577",
  "date_of_birth": new Date("2002-04-29"),
  "address": "Mirpur, Dhaka, Bangladesh",
  "profile_creation_date": new Date(),
  "working_status": "Software Developer",
  "bios": "Gooner",
  "hobbies": ["Music", "Movies", "Gaming", "Sleeping"],
  "following": [],
  "followers": []
})


/*  2(d)  */
db.user.updateOne(
  { "_id": ObjectId("64100b58d87392106fab76f5") },  // provide the actual ObjectIds
  { $set: { "following":  ObjectId("64100a89d87392106fab76f4") } } // provide the actual ObjectIds of the followers
)

db.user.updateOne(
  { "_id": ObjectId("64157ee38af25edbd00307b0") },  // provide the actual ObjectIds
  { $set: { "following":  [ ObjectId("64100a89d87392106fab76f4"), ObjectId("64157d5d8af25edbd00307af") ]  } } 
  // provide the actual ObjectIds of the followers
)


/*  2(e)  */
db.post.insertOne({
  "user_id": ObjectId("64100a89d87392106fab76f4"), // provide the actual ObjectId of the user who created the post
  "content": "This has been MAK!",
  "likes": 134510,
  "comments": ["Noice", "Luv it!"],
  "created_at": new Date()
})

db.post.insertMany([
    
  {
    "user_id": ObjectId("64100a89d87392106fab76f4"),  // provide the actual ObjectId of the user who created the post
    "content": "This has been MAK!",
    "likes": ["64157d5d8af25edbd00307af", "64157ee38af25edbd00307b0"],
    "comments": ["Noice", "Luv it!"],
    "created_at": new Date()
  },
  {
    "user_id": ObjectId("64157d5d8af25edbd00307af"),  // provide the actual ObjectId of the user who created the post
    "content": "Yo!",
    "likes": ["64100a89d87392106fab76f4"],
    "comments": ["Noice", "Luv it!"],
    "created_at": new Date()
  }

]);


// var followers = [ ObjectId("64100a89d87392106fab76f4"), ObjectId("64100b58d87392106fab76f5") ]; // replace with the ObjectIds of the followers

// followers.forEach(function(follower) {
//     db.users.updateOne(
//         { "_id": ObjectId("64100b58d87392106fab76f5") }, // replace with the ObjectId of the user
//         { $push: { "followers": follower } }
//     )

//     db.users.updateOne(
//         { "_id": ObjectId("64100a89d87392106fab76f4") }, // replace with the ObjectId of the user
//         { $push: { "followers": follower } }
//     )
// })


/*  2(f)  */
db.post.updateMany(                        //  deleting all of the elements of an array
  {  },                                   //   here, we are modifying each element
  { $set: { comments: [] } }
)


db.post.updateMany(         // match documents with user_ids in the specified list (it could've had more user_ids)
  { user_id: { $in: [ObjectId("64100a89d87392106fab76f4")] } },  
  { $push: { comments: { $each: [ 
      { text: "Noice!", user_id: ObjectId("64157d5d8af25edbd00307af") },
      { text: "Luv it!", user_id: ObjectId("64157ee38af25edbd00307b0") }
      ] } } 
  }
)



/*  3(a)  */

db.post.aggregate([{$sort:{createdAt: -1}}])     //  Descending order: "-1"

db.post.find().sort({created_at: -1})


/*  3(b)  */

db.post.aggregate([
  {
     $match: {
        created_at: {                                        // $gt = greater than 
           $gt: new Date(Date.now() - 24*60*60*1000)        //  in milliseconds, 
        }
     }
  },
  {
     $sort: {
        created_at: -1     // Descending order
     }
  }
])

db.post.find({created_at: {$gt: new Date(Date.now() - 24*60*60*1000)}})     // in milliseconds 

// new Date(Date.now()-24*60*60*1000)}}) is used to calculate the timestamp of 24 hours ago from the current date, 
// which is then used as the lower bound for the query to find all posts created within the last 24 hours.



/*  3(c)  */

db.user.find({ $expr: { $gt: [ {$size: "$followers"}, 1 ] } })   
// "$expr" is used to compare the values of the size and the provided value

db.user.aggregate([
  {
    $project: {                           // defining what to project
      _id: 1,
      name: 1,
      followersCount: { $size: "$followers" }   // getting the size
    }
  },
  {
    $match: {
      followersCount: { $gt: 1 }      // more than one followers
    }
  },
  {
    $project: {            // "1" means true
      _id: 1,
      name: 1,
      followersCount: 1
    }
  }
])



/*  3(d)  */

db.user.find({ $expr: { $gt: [ {$size: "$following"}, 1 ] } })   
// "$expr" is used to compare the values of the size and the provided value

db.user.aggregate([
  {
    $project: {                           // defining what to project
      _id: 1,
      name: 1,
      followingCount: { $size: "$following" }   // getting the size
    }
  },
  {
    $match: {
      followingCount: { $gt: 1 }      // more than one followings
    }
  },
  {
    $project: {            // "1" means true
      _id: 1,
      name: 1,
      followingCount: 1
    }
  }
])
  