import CoreConcept from "./CoreConcept"
import { CORE_CONCEPTS } from "../../data"
import './CoreConcept.css'
import Section from "../Section/Section"

export default function CoreConcepts(){
    return(
        <Section title='core-concept' id="core-concepts">
          <ul>
            {CORE_CONCEPTS.map((item)=>(<CoreConcept {...item}/>) )}
          </ul>
        </Section>
    )
}