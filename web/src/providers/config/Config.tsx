import React, { createContext, useContext, useState, ReactNode } from 'react';
import { useNuiEvent } from '../nui/useNui';

type Locale = {
    [key: string]: string;
}

export type Config = {
    loaded?: boolean;
    locale: Locale;
    currency: {
        name: string;
        locale: string;
    };
}

interface ConfigContextProps {
    config: Config;
    setConfig: (newConfig: Config) => void;
}

const ConfigContext = createContext<ConfigContextProps | undefined>(undefined);

interface ConfigProviderProps {
    children: ReactNode;
}

export const ConfigProvider: React.FC<ConfigProviderProps> = ({ children }) => {
    const [config, setConfig] = useState<Config>({
        locale: {},
        currency: {
            name: "USD",
            locale: "en-US"
        }
    });

    useNuiEvent("setConfig", function(config) {
        console.log("Setting config", config);
        setConfig(config);
    });

    return (
        <ConfigContext.Provider value={{ config, setConfig }}>
            {children}
        </ConfigContext.Provider>
    );
};

export const useConfig = (): ConfigContextProps => {
    const context = useContext(ConfigContext);
    if (!context) {
        throw new Error('useConfig must be used within a ConfigProvider');
    }
    return context;
};