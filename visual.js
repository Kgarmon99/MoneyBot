document.addEventListener('DOMContentLoaded', () => {
    const memeFeed = document.querySelector('.meme-feed'); // Ensure this matches the class in HTML
    const promoVideo = document.getElementById('promo-video'); // Ensure this ID matches your video element


    const memes = [
        'Visual/The3Statements.jpg',
        'Visual/IMG_3217.jpeg', // 6 Margins
        'Visual/IMG_3218.jpeg', // working backwards from net income
        'Visual/IMG_3220.jpeg', // financial reports
        'Visual/shootyourshot.jpeg',
        'Visual/IMG_4345.jpeg',
        'Visual/IMG_4339.jpeg',
        'Visual/IMG_4340.jpeg',
        'Visual/IMG_4334.jpeg',
        'Visual/IMG_1947.jpeg',
        'Visual/IMG_4325.jpeg',
        'Visual/IMG_4343.jpeg',
        'Visual/salesmasterclass.jpeg',
        'Visual/IMG_0053.jpeg',
        'Visual/IMG_4321.jpeg',
        'Visual/IMG_2871.png',

        'Visual/shootyourshot.jpeg',
        'Visual/AllThatMatters(Obsession).jpg',
        'Visual/CompoundInterest(Obsession).jpg',
        'Visual/DontWait(Obsession).jpg',
        'Visual/InspirationISperishable.jpg',
        'Visual/SayNo.jpg',
        'Visual/startnow.jpeg',
        'Visual/reputationasset.jpeg',
        'Visual/patience.jpeg',
        'Visual/ScaleYourself.jpg',
        'Visual/MindDomination.jpg',
        'Visual/distracted.png',
        'Visual/mjfocus.jpeg',
        'Visual/compound1.jpeg',
        'Visual/rep.jpeg',
        'Visual/RuleYourMind.jpeg',
        'Visual/IMG_9434.jpeg',
        'Visual/IMG_8618.jpeg',
        'Visual/IMG_8616.jpeg',
        'Visual/IMG_2139.jpeg',
        'Visual/MistakesVSFailures.jpeg',
        'Visual/TinyGains.jpeg',
        'Visual/IMG_8608.jpeg',
        'Visual/coldwater.jpeg',
        'Visual/consistency.jpeg',
        'Visual/IMG_3117.jpeg', // true artists build worlds
        'Visual/IMG_3129.jpeg', // take a simple thing to extreme lengths
        'Visual/IMG_3132.jpeg', // The doers are the thinkers
        'Visual/IMG_3151.jpeg', // Hard work
        'Visual/IMG_3160.jpeg', // The upward Spiral
        'Visual/IMG_3164.jpeg', // Wake Up
        'Visual/IMG_3175.jpeg', // The Future is Not Given
        'Visual/IMG_3242.jpeg', // entrepreneurs misunderstood
        'Visual/IMG_3263.jpeg', // Truth and Clarity
        'Visual/IMG_3268.jpeg', // Seven types of income
        'Visual/IMG_3270.jpeg',
        'Visual/IMG_3277.jpeg',
        'Visual/IMG_3290.jpeg',
        'Visual/IMG_3310.jpeg',
        'Visual/IMG_3311.jpeg',
        'Visual/IMG_3312.jpeg',
        'Visual/IMG_3341.png',
        'Visual/IMG_3392.jpeg',
        'Visual/IMG_3401.jpeg',
        'Visual/IMG_3501.jpeg',
        'Visual/IMG_3514.jpeg',
        'Visual/IMG_3516.jpeg',
        'Visual/IMG_3518.jpeg',
        'Visual/IMG_3540.jpeg',
        'Visual/IMG_3608.jpeg',
        'Visual/IMG_4219.jpeg',
        'Visual/IMG_4336.jpeg',
        'Visual/IMG_4532.jpeg',
        'Visual/IMG_4565.jpeg',
        'Visual/IMG_4571.png',
        'Visual/IMG_5417.jpeg',
        'Visual/IMG_5418.jpeg',
        'Visual/IMG_5711.jpeg',
        'Visual/IMG_6449.jpeg',
        'Visual/IMG_0201.jpeg',
        'Visual/IMG_1499.jpeg',
        'Visual/IMG_1956.jpeg',
        'Visual/IMG_2102.jpeg',
        'Visual/IMG_2230.jpeg',
        'Visual/IMG_2851.jpeg',
        'Visual/IMG_2871.png',
        'Visual/IMG_3356.jpeg',
        'Visual/IMG_8604.jpeg',
        'Visual/IMG_8608.jpeg',
        'Visual/IMG_8613.jpeg',
        'Visual/IMG_8616.jpeg',
        'Visual/IMG_8617.jpeg',
        'Visual/IMG_8618.jpeg',
        'Visual/IMG_9679.png',
        'Visual/IMG_9684.jpeg',
        'Visual/IMG_4316.jpeg',
        'Visual/IMG_4317.jpeg',
        'Visual/IMG_4318.jpeg',
        'Visual/IMG_4319.jpeg',
        'Visual/IMG_4320.jpeg',
        'Visual/IMG_4321.jpeg',
        'Visual/IMG_4323.jpeg',
    ];

const uniqueMemes = [...new Set(memes)]; // Remove duplicates
    const memesPerLoad = 10; // Number of memes to load each time
    let memeIndex = 0;

    const createMemeItem = (src) => {
        const memeItem = document.createElement('div');
        memeItem.classList.add('meme-item');

        const memeImage = document.createElement('img');
        memeImage.src = src;
        memeImage.alt = 'Meme';
        memeImage.classList.add('meme-image');

        memeItem.appendChild(memeImage);
        return memeItem; // Return the meme item
    };

    const loadMoreMemes = () => {
        const fragment = document.createDocumentFragment();
        for (let i = 0; i < memesPerLoad; i++) {
            if (memeIndex >= uniqueMemes.length) {
                memeIndex = 0; // Reset index to loop back to the beginning
            }
            const memeItem = createMemeItem(uniqueMemes[memeIndex]);
            fragment.appendChild(memeItem);
            memeIndex++;
        }
        memeFeed.appendChild(fragment);
    };

    // Load initial memes
    loadMoreMemes();

    // Infinite scroll logic
    window.addEventListener('scroll', () => {
        if (window.innerHeight + window.scrollY >= document.body.offsetHeight - 10) {
            loadMoreMemes();
        }
    });

    // Optional: Add fullscreen toggle feature for meme images
    memeFeed.addEventListener('click', (event) => {
        if (event.target.tagName === 'IMG') {
            event.target.classList.toggle('fullscreen');
        }
    });

