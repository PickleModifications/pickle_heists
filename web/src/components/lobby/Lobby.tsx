import { useState } from "react";
import { Player, Position } from "../../App";
import { HeistInfo } from "../heists/Heists";
import { Button, Flex, Slider, Text } from "@mantine/core";
import { useLocale } from "../../providers/locale/Locale";
import { useConfig } from "../../providers/config/Config";
import { Currency } from "../../providers/currency/Currency";
import classes from "./Lobby.module.css";
import { useNuiEvent } from "../../providers/nui/useNui";
import { fetchNui } from "../../providers/nui/fetchNui";

export type LobbyPlayer = Player & {
    position?: Position;
}

export type Lobby = {
    id: number;
    isLeader?: boolean;
    heistInfo: HeistInfo;
    players: Record<number, LobbyPlayer>;
    vehicles: Vehicle[];
    playerPercentages?: Record<number, number>;
}

export type Vehicle = {
    name: string;
    description: string;
    price: number;
}

type ArrowProps = {
    onClick: () => void;
    style?: React.CSSProperties;
}

function ArrowRight({ onClick, style }: ArrowProps) {
    return (
        <svg xmlns="http://www.w3.org/2000/svg" fill="white" height="30px" width="30px" version="1.1" id="Layer_1" viewBox="0 0 404.258 404.258" onClick={onClick} style={{cursor: "pointer", ...style}}>
            <polygon xmlns="http://www.w3.org/2000/svg" points="112.814,0 91.566,21.178 273.512,203.718 91.566,386.258 112.814,407.436 315.869,203.718 "/>
        </svg>
    );
}

function ArrowLeft({ onClick, style }: ArrowProps) {
    return (
        <svg xmlns="http://www.w3.org/2000/svg" fill="white" height="30px" width="30px" version="1.1" id="Layer_1" viewBox="0 0 404.258 404.258" onClick={onClick} style={{cursor: "pointer", ...style}}>
            <polygon points="289.927,18 265.927,0 114.331,202.129 265.927,404.258 289.927,386.258 151.831,202.129 "/>
        </svg>
    );
}

function ColorSelect({onSelect}: {onSelect?: (color: string) => void}) {
    const colors = [
        "#EF4444",
        "#F97316",
        "#EAB308",
        "#16A34A",
        "#0284C7",
        "#A855F7",
        "#ffffff",
        "#000000"
    ];
    const colorSize = 30;
    return (
        <Flex style={{gap: 5}}>
            {colors.map((color) => (
                <div key={color} style={{cursor: "pointer", width: colorSize, height: colorSize, border: "white 2px solid", background: color, borderRadius: colorSize}} onClick={() => onSelect && onSelect(color)}/>
            ))}
        </Flex>
    );
}

function HexToRGB(hex: string) {
    let r = 0, g = 0, b = 0;
    if (hex.length == 7) {
        r = parseInt(hex.substring(1, 3), 16);
        g = parseInt(hex.substring(3, 5), 16);
        b = parseInt(hex.substring(5, 7), 16);
    }
    return {r, g, b};
}

export default function LobbyApp() {
    const {config} = useConfig();
    const translate = useLocale();
    const [lobby, setLobby] = useState<Lobby | null>(null /*{
        id: 0,
        isLeader: false,
        heistInfo: {
            label: "The Flecca Job",
            description: "A high-stakes bank heist that requires careful planning and precise execution. Assemble your crew, gather intel, and prepare for an intense showdown with law enforcement. The payout is substantial, but so are the risks. Will you and your team make it out with the loot, or will you end up behind bars? The Flecca Job is not for the faint of heart.",
            reward: 1000
        },
        players: [
            { source: 1, identifier: "steam:12345", name: "Player 1"},
            { source: 2, identifier: "steam:54321", name: "Player 2"},
            { source: 3, identifier: "steam:67890", name: "Player 3"}
        ],
        vehicles: [
            { name: "Karin Kuruma", description: "A heavily armored sports car that is perfect for heists. It can take a lot of damage and has plenty of firepower to help you get out of sticky situations.", price: 50000 },
            { name: "Vapid Dominator", description: "A classic muscle car that is fast, powerful, and stylish. It is perfect for making a quick getaway after a heist.", price: 30000 },
        ]
    }*/);
    const [currentSection, setCurrentSection] = useState<string>("main");
    const [showSection, setShowSection] = useState<boolean>(true);
    const sectionTransition = (section: string) => {
        fetchNui("setSection", section);
        setSelectedPlayerTarget(null);
        setShowSection(false);
        setTimeout(() => {
            setShowSection(true);
            setCurrentSection(section);
        }, 500);
    }
    // Main
    const [playerPercentages, setPlayerPercentages] = useState<Record<number, number>>(lobby?.playerPercentages || {});
    useNuiEvent("setLobby", (data) => {
        if (data.lobby == null) {
            setCurrentSection("main");
            setShowSection(true);
        }
        if (data.lobby && data.lobby.players) {
            for (const key in data.lobby.players) {
                if (data.lobby.players[key].position) {
                    let width = window.innerWidth;
                    let height = window.innerHeight;
                    let offsetWidth = 30;
                    let offsetHeight = 30;
                    data.lobby.players[key].position.x = ((width - offsetWidth) * data.lobby.players[key].position.x);
                    data.lobby.players[key].position.y = ((height - offsetHeight) * data.lobby.players[key].position.y);
                }
            }
        }
        if (data.lobby && data.lobby.playerPercentages) {
            setPlayerPercentages(data.lobby.playerPercentages);
        }
        setLobby(data.lobby);
    });
    const updatePlayerPercentage = (source: number, percentage: number) => {
        let maxPercentage = 100 - Object.entries(playerPercentages).filter(([key, value]) => parseInt(key) !== source).reduce((acc, [key, val]) => acc + val, 0);
        setPlayerPercentages((prev) => ({
            ...prev,
            [source]: percentage > maxPercentage ? maxPercentage : percentage
        }));
    }
    const [requirePercentUpdate, setRequirePercentUpdate] = useState<boolean>(false);
    if (requirePercentUpdate) {
        fetchNui("updatePlayerPercentages", Object.entries(playerPercentages).map(([key, value]) => ({source: parseInt(key), percentage: value})));
        setRequirePercentUpdate(false);
    }
    const [selectedPlayerTarget, setSelectedPlayerTarget] = useState<number | null>(null);
    // Vehicle Selection
    const [selectedVehicle, setSelectedVehicle] = useState<number | null>(null);
    const [currentVehicle, setCurrentVehicle] = useState<number>(0);
    if (!lobby) return null;
    // for (const player of lobby.players) {
    //     if (!lobbyPlayerTargets[player.source]) {
    //         setLobbyPlayerTargets((prev) => ({
    //             ...prev,
    //             [player.source]: {
    //                 position: {
    //                     x: Math.random() * window.innerWidth,
    //                     y: Math.random() * window.innerHeight
    //                 }
    //             }
    //         }));
    //     }
    // }
    if (selectedPlayerTarget != null && !lobby.players[selectedPlayerTarget]) {
        setSelectedPlayerTarget(null);
    }
    for (const key in playerPercentages) {
        if (!Object.values(lobby.players).find((player) => player.source === parseInt(key))) {
            setPlayerPercentages((prev) => {
                const copy = { ...prev };
                delete copy[key];
                return copy;
            });
        }
    }
    const setNextVehicle = (forward: boolean) => {
        let newIndex = currentVehicle + (forward ? 1 : -1);
        if (newIndex < 0) {
            newIndex = lobby.vehicles.length - 1;
        } else if (newIndex >= lobby.vehicles.length) {
            newIndex = 0;
        }
        setCurrentVehicle(newIndex);
        fetchNui("setVehicle", newIndex + 1);
    }

    return (
        <div style={{position: "relative", width: "100%", height: "100vh", overflow: "hidden", opacity: showSection ? 1 : 0, transition: "opacity 0.5s"}}>
            {(currentSection == "main") ? (
                <>
                    <Flex pos={"absolute"} c={"white"} justify={"space-between"} align={"end"} style={{
                        bottom: 0,
                        left: 0,
                        width: "100%",
                        padding: 40,
                        paddingTop: "25%",
                        background: "linear-gradient(to top, rgba(0, 0, 0, 0.85), transparent)"
                    }}>
                        <div style={{ userSelect: "none", width: "100%" }}>
                            <Text fz={"h1"} fw={"bold"}>{lobby.heistInfo.label}</Text>
                            <Flex justify={"space-between"} w={"100%"} align={"center"} style={{gap: 20}}>
                                <Text c={"gray.3"} fz={"h3"} maw={1000}>{lobby.heistInfo.description}</Text>
                                <Flex direction={"column"} align={"center"} style={{gap: 10}}>
                                    {(selectedVehicle != null || lobby.vehicles.length < 0) && (
                                        <Button onClick={() => fetchNui("startHeist", {})} color={"green.7"} size={"xl"} w={300} fz={"h2"}>{translate("heist_start")}</Button>
                                    )}
                                    {(lobby.vehicles.length > 0) && (
                                        (selectedVehicle != null) ? (
                                            <Button onClick={() => sectionTransition("vehicle")} color={"gray.7"} size={"md"} w={300} fz={"md"}>{translate("heist_vehicle_change")}</Button>
                                        ) :
                                        (
                                            <Button onClick={() => sectionTransition("vehicle")} color={"gray.7"} size={"xl"} w={300} fz={"h2"}>{translate("heist_vehicle_select")}</Button>
                                        )
                                    )}
                                    <Button onClick={() => fetchNui("leaveHeist", {})} color={"red.7"} size={"md"} w={300} fz={"md"}>{translate("heist_leave")}</Button>
                                    <Flex style={{gap: 5}}>
                                        <Text fz={"lg"}>{translate("heist_reward")}</Text>
                                        <Text fw={"bold"} fz={"lg"}>{Currency(lobby.heistInfo.reward, config)}</Text>
                                    </Flex>
                                </Flex>
                            </Flex>
                        </div>
                    </Flex>
                    {
                        Object.entries(lobby.players).map(function ([key, player]) {
                            let playerPercentage = playerPercentages[player.source] || 0;
                            if (!player.position) return;
                            return (
                                <div key={key} className={classes.playerTargetContainer} style={{top: player.position.y, left: player.position.x}}>
                                    <Flex gap={10}>
                                        <div className={classes.playerTarget} onClick={() => setSelectedPlayerTarget(parseInt(key) === selectedPlayerTarget ? null : parseInt(key))}>
                                            <svg style={{position: "absolute", top: "50%", left: "50%", transform: "translate(-45%, -50%)"}} xmlns="http://www.w3.org/2000/svg" fill="white" width="20px" height="20px" viewBox="0 0 16 16">
                                                <path d="m7 7.88c2.18 0 3.94-1.76 3.94-3.94s-1.76-3.94-3.94-3.94c-2.17 0-3.94 1.76-3.94 3.94 0 2.17 1.77 3.94 3.94 3.94zm1.09 3.24c-.26-.52-.17-1.17.26-1.6l.28-.27c.05-.05.12-.08.18-.12h-4.31c-2.48.01-4.5 2.02-4.5 4.5 0 .12.01.25.03.38h7.95c-.44-.23-.74-.68-.74-1.21v-.4c0-.57.35-1.07.85-1.28zm6.76.7h-.98c-.06-.19-.14-.36-.24-.53l.65-.65c.15-.15.15-.4 0-.55l-.27-.27c-.15-.15-.4-.15-.55 0l-.66.66c-.18-.1-.37-.18-.58-.23v-.86c0-.21-.17-.39-.39-.39h-.39c-.21 0-.39.17-.39.39v.85c-.22.06-.43.15-.63.26l-.54-.54c-.15-.15-.4-.15-.55 0l-.28.27c-.15.15-.15.4 0 .55l.56.56c-.12.21-.21.43-.26.67h-.72c-.22 0-.39.17-.39.39v.39c0 .21.17.39.39.39h.78c.07.23.18.45.31.65l-.53.53c-.15.15-.15.4 0 .55l.27.27c.15.15.4.15.55 0l.59-.59c.2.1.41.17.64.21v.81c0 .21.17.39.39.39h.39c.21 0 .39-.17.39-.39v-.91c.2-.07.38-.16.55-.28l.63.63c.15.15.4.15.55 0l.27-.27c.15-.15.15-.4 0-.55l-.69-.69c.08-.17.15-.35.19-.55h.93c.22 0 .39-.17.39-.39v-.39c.01-.22-.17-.39-.38-.39zm-3.21 1.65c-.54 0-.97-.43-.97-.97s.44-.97.97-.97c.54 0 .97.43.97.97s-.43.97-.97.97z"/>
                                            </svg>
                                        </div>
                                        <Flex className={(parseInt(key) == selectedPlayerTarget ? classes.playerTargetMenu : classes.playerTargetMenuHide)} direction={"column"} style={{color: "white", background: "rgba(0, 0, 0, 0.75)", borderRadius: "5px", padding: 10, display: "flex", transition: "scale 0.2s"}}>
                                            <Text pl={5} pr={5} fz={"xl"} fw={"bold"}>{translate("heist_player", player.name, player.source)}</Text>
                                            <Text pl={5} pr={5}>{translate("heist_set_cut", playerPercentage)}</Text>
                                            {(lobby.isLeader && player.source != config.source) ? (
                                                <>
                                                    <Slider color="gray.7" pl={14} pr={14} value={playerPercentage} onChangeEnd={() => {
                                                        setRequirePercentUpdate(true);
                                                    }} onChange={(value) => {
                                                        updatePlayerPercentage(player.source, value);
                                                    }} min={0} max={100} step={1}/>
                                                    <Text onClick={() => fetchNui("kickPlayer", player.source)} className={classes.playerTargetOption}>{translate("heist_kick")}</Text>
                                                    <Text onClick={() => fetchNui("promotePlayer", player.source)} className={classes.playerTargetOption}>{translate("heist_promote")}</Text>
                                                </>
                                            ) : null}
                                        </Flex>
                                    </Flex>
                                </div>
                            );
                        })
                    }
                </>
            ) : null}
            {(currentSection == "vehicle") ? (
                <Flex pos={"absolute"} c={"white"} justify={"space-between"} align={"end"} style={{
                    bottom: 0,
                    left: 0,
                    width: "100%",
                    padding: 40,
                    paddingTop: "25%",
                    background: "linear-gradient(to top, rgba(0, 0, 0, 0.85), transparent)"
                }}>
                    <div style={{ userSelect: "none", width: "100%" }}>
                        <Text fz={"h1"} fw={"bold"}>{lobby.vehicles[currentVehicle].name}</Text>
                        <Text fw={"bold"} fz={"h2"}>{Currency(lobby.vehicles[currentVehicle].price, config)}</Text>

                        <Flex justify={"space-between"} w={"100%"} align={"center"} style={{gap: 20}}>
                            <Text c={"gray.3"} fz={"h3"} maw={1000}>{lobby.vehicles[currentVehicle].description}</Text>
                            <Flex direction={"column"} align={"center"} style={{gap: 10}}>
                                <ColorSelect onSelect={(color) => {fetchNui("setVehicleColor", HexToRGB(color))}}/>
                                <Flex align={"center"} style={{gap: 10}}>
                                    <ArrowLeft onClick={() => setNextVehicle(false)}/>
                                    <Button onClick={() => {
                                        setSelectedVehicle(currentVehicle);
                                        sectionTransition("main");
                                    }} color={"green.7"} size={"xl"} w={300} fz={"h2"}>{translate("heist_vehicle_select")}</Button>
                                    <ArrowRight onClick={() => setNextVehicle(true)}/>
                                </Flex>
                            </Flex>
                        </Flex>
                    </div>
                </Flex>
            ) : null}
        </div>
    );
}