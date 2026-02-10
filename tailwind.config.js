/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                primary: {
                    DEFAULT: 'var(--primary)',
                    hover: 'var(--primary-hover)',
                    glow: 'var(--primary-glow)',
                },
                background: 'var(--bg-app)',
                surface: 'var(--bg-panel)',
                input: 'var(--bg-input)',
                text: {
                    DEFAULT: 'var(--text-main)',
                    muted: 'var(--text-muted)',
                },
            },
            fontFamily: {
                sans: ['Inter', 'sans-serif'],
            },
            borderRadius: {
                DEFAULT: 'var(--radius)',
                full: 'var(--radius-full)',
            },
            animation: {
                fadeIn: 'fadeIn 0.5s ease-out',
            },
            keyframes: {
                fadeIn: {
                    '0%': { opacity: '0', transform: 'translateY(10px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
            },
        },
    },
    plugins: [],
}
