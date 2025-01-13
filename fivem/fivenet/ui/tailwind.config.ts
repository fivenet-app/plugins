import type { Config } from 'tailwindcss';
import { fontFamily } from 'tailwindcss/defaultTheme';

export default <Partial<Config>>{
    mode: 'jit',
    content: [
        `./app/components/**/*.{vue,js,ts}`,
        `./app/layouts/**/*.vue`,
        `./app/pages/**/*.vue`,
        `./app/composables/**/*.{js,ts}`,
        `./app/plugins/**/*.{js,ts}`,
        `./app/store/**/*.{js,ts}`,
        `./app/utils/**/*.{js,ts}`,
        `./app/App.{js,ts,vue}`,
        `./app/app.{js,ts,vue}`,
        `./app/Error.{js,ts,vue}`,
        `./app/error.{js,ts,vue}`,
        `./app/app.config.{js,ts}`,
        `./nuxt.config.{js,ts}`,
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['DM Sans', ...fontFamily.sans],
            },
        },
    },
};
