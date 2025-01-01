import { useState } from "react";
import { useConfig } from "../../providers/config/Config";
import { useLocale } from "../../providers/locale/Locale";

import classes from "./Heists.module.css";
import { Flex, Text, useMantineTheme } from "@mantine/core";

export type ObjectiveStruct = {
    label: string;
    description: string;
    completed: boolean;
}

export type Heist = {
    label: string;
    description: string;
    reward: number;
    stageDescription?: string;
    objectives?: ObjectiveStruct[];
}

function Checkbox({checked, style} : {checked : boolean, style?: React.CSSProperties}) {
    const theme = useMantineTheme();
    return (checked ? (
        <svg xmlns="http://www.w3.org/2000/svg" width="30px" height="30px" viewBox="0 0 24 24" version="1.1" style={style}>
            <g id="🔍-Product-Icons" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                <g id="ic_fluent_checkbox_checked_24_regular" fill={theme.colors.green[4]} fill-rule="nonzero">
                    <path d="M18.25,3 C19.7687831,3 21,4.23121694 21,5.75 L21,18.25 C21,19.7687831 19.7687831,21 18.25,21 L5.75,21 C4.23121694,21 3,19.7687831 3,18.25 L3,5.75 C3,4.23121694 4.23121694,3 5.75,3 L18.25,3 Z M18.25,4.5 L5.75,4.5 C5.05964406,4.5 4.5,5.05964406 4.5,5.75 L4.5,18.25 C4.5,18.9403559 5.05964406,19.5 5.75,19.5 L18.25,19.5 C18.9403559,19.5 19.5,18.9403559 19.5,18.25 L19.5,5.75 C19.5,5.05964406 18.9403559,4.5 18.25,4.5 Z M10,14.4393398 L16.4696699,7.96966991 C16.7625631,7.6767767 17.2374369,7.6767767 17.5303301,7.96966991 C17.7965966,8.23593648 17.8208027,8.65260016 17.6029482,8.94621165 L17.5303301,9.03033009 L10.5303301,16.0303301 C10.2640635,16.2965966 9.84739984,16.3208027 9.55378835,16.1029482 L9.46966991,16.0303301 L6.46966991,13.0303301 C6.1767767,12.7374369 6.1767767,12.2625631 6.46966991,11.9696699 C6.73593648,11.7034034 7.15260016,11.6791973 7.44621165,11.8970518 L7.53033009,11.9696699 L10,14.4393398 L16.4696699,7.96966991 L10,14.4393398 Z" id="🎨Color">
                    </path>
                </g>
            </g>
        </svg>
    ): (
        <svg xmlns="http://www.w3.org/2000/svg" width="30px" height="30px" viewBox="0 0 24 24" version="1.1" style={style}>
            <g id="🔍-Product-Icons" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                <g id="ic_fluent_checkbox_unchecked_24_regular" fill={"white"} fill-rule="nonzero">
                    <path d="M5.75,3 L18.25,3 C19.7687831,3 21,4.23121694 21,5.75 L21,18.25 C21,19.7687831 19.7687831,21 18.25,21 L5.75,21 C4.23121694,21 3,19.7687831 3,18.25 L3,5.75 C3,4.23121694 4.23121694,3 5.75,3 Z M5.75,4.5 C5.05964406,4.5 4.5,5.05964406 4.5,5.75 L4.5,18.25 C4.5,18.9403559 5.05964406,19.5 5.75,19.5 L18.25,19.5 C18.9403559,19.5 19.5,18.9403559 19.5,18.25 L19.5,5.75 C19.5,5.05964406 18.9403559,4.5 18.25,4.5 L5.75,4.5 Z" id="🎨Color">
                    </path>
                </g>
            </g>
        </svg>
    ));
}

export default function HeistsHUDApp() {
    const {config} = useConfig();
    const translate = useLocale();
    const [heist, setHeist] = useState<Heist | null>({
        label: "The Fleeca Job",
        description: "Steal the diamonds",
        stage: {

        },
        reward: 10000,
        objectives: [
            {
                label: "Steal the diamonds",
                description: "Get the diamonds from the vault",
                completed: false
            },
            {
                label: "Escape the cops",
                description: "Lose the cops",
                completed: false
            },
            {
                label: "Deliver the diamonds",
                description: "Deliver the diamonds to the drop-off",
                completed: true
            }
        ]
    });
    return heist && (
        <div className={classes.heistsHUDContainer}>
            <Text fz={"lg"} fw={"bold"}>{heist.label}</Text>
            {heist.stageDescription && <Text fz={"md"}>{heist.stageDescription}</Text>}
            {heist.objectives && 
                heist.objectives.map((objective, index) => (
                    <Flex direction={"column"} key={index}>
                        <Flex align={"center"} gap={"xs"}>
                            <Checkbox style={{width: 20, height: 20}} checked={objective.completed}/>
                            <Text fz={"sm"} fw={600} >{objective.label}</Text>
                        </Flex>
                        <Text fz={"xs"} c={"gray.4"}>{objective.description}</Text>
                    </Flex>
                ))
        }
        </div>
    )
}