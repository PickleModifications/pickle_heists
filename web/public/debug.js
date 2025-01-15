document.addEventListener('DOMContentLoaded', (event) => {
    fetch('https://pickle_heists/requestConfig', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then((response) => {
        response.json().then((data) => {
            console.log('Sending config data to NUI', data);
            window.postMessage(data, '*');
        });
    });
});

document.addEventListener('DOMContentLoaded', (event) => {
    setTimeout(() => {
        window.postMessage({
            type: "setConfig",
            locale: {
                heist_start: "Start Heist",
                heist_reward: "Rewards up to",
                heist_vehicle_select: "Select Vehicle",
                heist_leave: "Leave Heist",
                heist_vehicle_change: "Change Vehicle",
                heist_player: "%s (ID: %s)",
                heist_set_cut: "Percentage (%s%)",
                heist_kick: "Kick Player",
                heist_promote: "Promote to Heist Leader",
            },
            currency: {
                name: "USD",
                locale: "en-US"
            },
        }, '*');
    }, 1000);
});