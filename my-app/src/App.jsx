import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import cat from './assets/cat.jpeg' // refrence in src/asset with vcariable name
function User(){
  return (
    <>
    <p>
      abhi
    </p>
    </>
  )


}
function Greetings(){

  return (
    <>
      <p>welcome to the world</p>
      <p>my name is {User()}</p>
      <img src={cat} />
      {/* reference from prublic folder */}
      <img src="/vite.svg"/>  
      
    </>

)
}

function App() {
  return(
    <div>
      <h2>
        Hello world
      </h2>
      <Greetings/>
    </div>
    
  );
  
};

export default App
