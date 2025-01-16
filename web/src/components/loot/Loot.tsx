import { useState } from "react";
import { Position } from "../../App";
import classes from "./Loot.module.css";
import { ControlAction } from "../controls/Controls";
import { Text } from "@mantine/core";

export type Loot = {
    image: string;
    label: string;
    description: string;
    amount: number;
    position: Position;
}

export default function LootApp() {
    const [loot, setLoot] = useState<Loot | null>({
        label: "The Mon-uhhhhhh Lisa?",
        image: "https://images.squarespace-cdn.com/content/v1/53d1d528e4b03aa34500543a/1414279357127-R362TN612Z0VKJ52CVZ7/mona+lisa+frame.jpg",
        description: "A beautiful painting valued at $10,000",
        amount: 1,
        position: {x: 200, y: 200}
    });
    const [position, setPosition] = useState<Position>(loot ? loot.position : {x: 200, y: 200});
    const contentPortion = 75;
    return loot && (
        <div className={classes.lootContainer} style={{left: position.x, top: position.y}}>
            <div style={{display:"flex", height: contentPortion+"%", padding: "6px"}}>
                <img src={loot.image} alt="loot" style={{maxWidth: "200px", maxHeight: "100%"}}/>
                <div style={{display:"flex", height: "100%", alignItems: "flex-end"}}>
                    <div style={{display:"flex", flexDirection: "column", gap: "0px", padding: "0px 6px"}}>
                        <div style={{display:"flex", gap: "6px", alignItems: "center"}}>
                        <Text fz={"lg"} fw={"bold"} c={"white"}>{loot.label}</Text>
                        <Text fz={"sm"} c={"gray.2"}>x{loot.amount}</Text>
                        </div>
                        <Text fz={"sm"} c={"gray.2"}>{loot.description}</Text>
                    </div>
                </div>
            </div>
            <div style={{gap: "6px", display:"flex", alignItems: "center", padding: "0px 6px", height: (100-contentPortion)+"%", borderTop: "1px solid white"}}>
                <ControlAction label={"E"}/>
                <Text fz={"md"} fw={"bold"} c={"white"}>Pickup Loot</Text>
            </div>
        </div>
    );
}