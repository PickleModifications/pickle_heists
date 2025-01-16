import React from "react"

export function ControlAction({label, containerStyle, textStyle} : {label: string, containerStyle?: React.CSSProperties,  textStyle?: React.CSSProperties}) { 
    return (
        <div style={{ display:"flex", alignItems: "center", justifyContent: "center", backgroundColor: "white", color: "black", height: "20px", minWidth: "20px", borderRadius: "4px", ...containerStyle}}>
            <div style={{fontWeight: 700, fontSize: 14, ...textStyle}}>{label}</div>
        </div>
    )
}