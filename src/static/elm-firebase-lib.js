// Initialize Firebase
var config = {
  apiKey: "AIzaSyDG-7OphM36BpQkMuNvVbsOxdGx0kgADvY",
  authDomain: "prova-ede5b.firebaseapp.com",
  databaseURL: "https://prova-ede5b.firebaseio.com",
  projectId: "prova-ede5b",
  storageBucket: "prova-ede5b.appspot.com",
  messagingSenderId: "475414347726"
};
firebase.initializeApp(config);

var provider = new firebase.auth.GoogleAuthProvider();
provider.setCustomParameters({prompt:"select_account"});
defaultStorage = firebase.storage();
defaultDatabase = firebase.database();



app.ports.toFirebase.subscribe(function(obj) {
  console.log(obj);


    if (obj.action == "set"){
      var ref = defaultDatabase.ref(obj.path);

      var newKey = ref.push().key;
      var updates = {};
      updates[ newKey] = obj.value;
      ref.update(updates);
    }else if (obj.action == "on"){

      var ref = defaultDatabase.ref(obj.path);
      ref.on(obj.event, function(snapshot) {
        snapshot.forEach(function(data) {
         console.log("The " + data.key + " score is " + data.val());
       });
      }, function (error) {
         console.log("Error: " + error.code);
      });

    }else if (obj.action == "IN"){
      signin();
    } else   if (obj.action == "OUT"){
      signout();
    } else   if (obj.action == "QUERY"){
      query();
    }else{
      console.log("command error: " + str );
    }

});

var signin = function() {
  firebase.auth().signInWithPopup(provider).then(function(result) {
    // This gives you a Google Access Token. You can use it to access the Google API.
    var token = result.credential.accessToken;
    // The signed-in user info.
    var user = result.user;
    // ...
    console.log(user.displayName);
    // app.ports.fromFirebase.send(user.displayName);

  }).catch(function(error) {
    // Handle Errors here.
    var errorCode = error.code;
    var errorMessage = error.message;
    // The email of the user's account used.
    var email = error.email;
    // The firebase.auth.AuthCredential type that was used.
    var credential = error.credential;
    // ...
    console.log(errorMessage);
    ret =  errorMessage;
    // app.ports.fromFirebase.send(error.message);
  });
};

var signout = function (){
  firebase.auth().signOut().then(function() {
    // app.ports.fromFirebase.send("SignOut");
  }).catch(function(error) {
    // app.ports.fromFirebase.send("SignOut Error");
  });

};

var query = function (){
  var ref = defaultDatabase.ref("aaa/-KjtXZUD0-O9edkBM5k2");

  ref.on("value", function(snapshot) {
     console.log("query val: " + snapshot.val());
     app.ports.fromFirebase.send(snapshot.val());
  }, function (error) {
     console.log("Error: " + error.code);
  });

};

query();
