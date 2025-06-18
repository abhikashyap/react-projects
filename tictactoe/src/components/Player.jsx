import { useState } from "react"
export default function Player({initialName,symbol}){

    const [isediting,setisediting]=useState(false)
    const [playerName,setPlayerName]=useState(initialName)
    function handleEditClick(){
        setisediting((editing)=>(!editing))
    }

    function handleChange(event){
        setPlayerName(event.target.value)
    }

    let editablePlayerName =<span className="player-name">{playerName}</span>;
    if (isediting){
        editablePlayerName=<input type="text" required defaultValue={playerName} onChange={handleChange}/>
    }

    
    return(
        <li>
            <span className="player">
                {editablePlayerName}
              
              <span className="player-symbol">{symbol}</span>
            </span>
            <button onClick={handleEditClick}>{isediting ? 'save' : 'Edit'}</button>
        </li>
    )
}