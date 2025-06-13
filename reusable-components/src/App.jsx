import './App.css'
import { CORE_CONCEPTS } from './data'
import Header from './components/Header/Header.jsx'
import CoreConcept from './components/CoreConcept/CoreConcept.jsx';
import TabButton from './components/Tab/Tab.jsx';
function App() {
  function HandleClick(selectedButton){
    console.log(selectedButton)
  }
  return (
    <div>
      <Header/>
      <main>
        <section id ="core-concepts">
          <ul>
            <CoreConcept
              title={CORE_CONCEPTS[0].title}
              image={CORE_CONCEPTS[0].image}
              description={CORE_CONCEPTS[0].description}
            />
            <CoreConcept {...CORE_CONCEPTS[1]}/>
            <CoreConcept {...CORE_CONCEPTS[2]}/>
            <CoreConcept {...CORE_CONCEPTS[3]}/>
          </ul>
        </section>
        <section id="examples">
          <h2>Examples</h2>
          <menu>
            <TabButton onSelect={()=>{HandleClick('components')}}>Components</TabButton>
            <TabButton onSelect={()=>{HandleClick('Jsx')}}>Jsx</TabButton>
            <TabButton onSelect={()=>{HandleClick('Props')}}>Props</TabButton>
            <TabButton onSelect={()=>{HandleClick('State')}}>State</TabButton>
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
          </menu>


        </section>
      </main>
    </div>
  );
}

export default App
