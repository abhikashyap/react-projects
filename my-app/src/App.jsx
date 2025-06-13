import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'

function Greetings(){
  return <p>welcome to the world</p>
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
