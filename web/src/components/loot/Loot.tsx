import { useEffect, useState } from "react";
import { Position } from "../../App";
import classes from "./Loot.module.css";
import { ControlAction } from "../controls/Controls";
import { Text } from "@mantine/core";
import { useConfig } from "../../providers/config/Config";
import { Currency } from "../../providers/currency/Currency";
import { useNuiEvent } from "../../providers/nui/useNui";

export type Loot = {
    image: string;
    label: string;
    description: string;
    amount: number;
    position: Position;
}

export default function LootApp() {
    const {config} = useConfig();
    const [configState, setConfigState] = useState(config);
    const [loot, setLoot] = useState<Loot | null>({
        label: "The Mon-uhhhhhh Lisa?",
        image: "https://images.squarespace-cdn.com/content/v1/53d1d528e4b03aa34500543a/1414279357127-R362TN612Z0VKJ52CVZ7/mona+lisa+frame.jpg",
        description: "A beautiful painting drawn by Da Vinci himself.",
        amount: 10000,
        position: {x: 200, y: 200}
    });
    const [position, setPosition] = useState<Position>(loot ? loot.position : {x: 0, y: 0});
    useEffect(() => {
        setConfigState(config);
    }, [config]);
    useNuiEvent("setLoot", (data) => {
        setLoot(data.loot)
    });
    useNuiEvent("setLootPosition", (data) => {
        setPosition(data.position);
    });
    return loot && (
        <div className={classes.lootContainer} style={{left: position.x, top: position.y}}>
            <div className={classes.lootInfo} style={{position: "relative", display:"flex", padding: "6px"}}>
                <img src={loot.image} alt="loot" style={{position: "absolute", bottom: 12, left: 12, width: "75px"}}/>
                <div style={{display:"flex", height: "100%", alignItems: "flex-end"}}>
                    <div style={{display:"flex", marginLeft: 87, paddingTop: 10, flexDirection: "column", gap: "0px", padding: "0px 6px"}}>
                        <div style={{display:"flex", gap: "6px", alignItems: "center"}}>
                        <Text fz={"lg"} fw={"bold"} c={"white"}>{loot.label}</Text>
                        </div>
                        <Text fz={"sm"} c={"gray.6"}>{loot.description}</Text>
                    </div>
                </div>
            </div>
            <div className={classes.lootControls} style={{gap: "6px", display:"flex", alignItems: "center", padding: "6px 12px", borderTop: "1px solid #27272A"}}>
                <ControlAction label={"E"}/>
                <Text fz={"md"} fw={"bold"} c={"white"}>Pickup</Text>                        
                <Text fz={"sm"} c={"gray.6"}>{Currency(loot.amount, config)}</Text>
            </div>
        </div>
    );
}