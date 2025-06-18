export default function Tabs({buttons,children,buttonContainer='menu'}){
    const ButtonContainer = buttonContainer
    return (<>
    <ButtonContainer>
        {buttons}
    </ButtonContainer>
    {children}
    </>)
}