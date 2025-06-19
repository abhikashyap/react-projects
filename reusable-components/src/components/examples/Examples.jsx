import TabButton from "../Tab/Tab";
import { EXAMPLES } from "../../data.js";
import { useState } from "react";
import Section from '../Section/Section.jsx'
import Tabs from "../Tab/Tabs";
export default function Examples(){
    const [selectedTopic, setSelectedTopic] = useState();
    function HandleClick(selectedButton) {
        setSelectedTopic(selectedButton);
    }
    let tabContent = <p>Please select a topic</p>
    if (selectedTopic){
        tabContent=(
        <div id="tab-content">
            <h3>{EXAMPLES[selectedTopic].title}</h3>
            <p>{EXAMPLES[selectedTopic].description}</p>
            <pre>
                <code>{EXAMPLES[selectedTopic].code}</code>
            </pre>
          </div>
        )

    }
    
    return(
        <Section title='Examples'id="examples">
          <Tabs 

          buttons= {<>
            <TabButton
              isSelected={selectedTopic === 'components'}
              onClick={() => {
                HandleClick("components");
              }}
            >
              Components
            </TabButton>
            <TabButton
            isSelected={selectedTopic === 'jsx'}
              onClick={() => {
                HandleClick("jsx");
              }}
            >
              jsx
            </TabButton>
            <TabButton
              isSelected={selectedTopic === 'props'}
              onClick={() => {
                HandleClick("props");
              }}
            >
              props
            </TabButton>
            <TabButton
              isSelected={selectedTopic === 'state'}
              onClick={() => {
                HandleClick("state");
              }}
            >
              state
            </TabButton>
          
          </>}
          >
            {tabContent}

          </Tabs>
            
            {/* can i say i created a button component which i used 4 times and i wanted functionality of click on all but all the click 
            should befhave differently so i modified on click to on Select
             button which when invokedd will invoke a function HandleClick
              which takes in all parameters from the button and pass in required 
              paremeters to handleclick buitton whose job is to execute task based 
              on arguments recieved


              ChatGPT said:
              Yes, you're on the right track! Here's a more polished and technically clear way to describe what you did:

              ✅ Refined Version
              I created a reusable TabButton component and used it four times in my app. I needed each button to trigger a different action when clicked.

              To achieve this, I passed a custom onSelect prop to each TabButton, which accepts a callback function.

              Inside the parent component (App), I defined a handleSelect function that receives a parameter indicating which tab was clicked (e.g., "Components", "Props").

              Each TabButton calls this function with its own unique argument, allowing a single handler to control different behaviors based on the selected tab.

              */}

          
        </Section>
    )
}