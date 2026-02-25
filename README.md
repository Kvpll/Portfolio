# Kvpll's Roblox Scripting Portfolio

A clean, modern portfolio website showcasing Roblox scripting experience and projects.

## Features

✨ **Clean, Human-Written Code** - Simple and readable CSS, HTML, and JavaScript
🎮 **Portfolio Sections** - Projects, code snippets, about, and contact areas
📱 **Fully Responsive** - Works perfectly on desktop, tablet, and mobile
🎨 **Modern Design** - Professional styling with smooth animations
🔗 **Social Media Integration** - Discord, Telegram, Roblox, GitHub links

## File Structure

```
Portfolio/
├── index.html      # Main HTML file with all sections
├── styles.css      # Clean CSS styling and responsive design
├── script.js       # Simple JavaScript for interactivity
└── README.md       # This file
```

## Customization Guide

### 1. Update Your Contact Information

In `index.html`, find the Contact section and update:

- **Discord** - Replace `YOUR_DISCORD_ID` with your actual Discord user ID
- **Telegram** - Replace `YOUR_TELEGRAM_USERNAME` with your Telegram username
- **Roblox Profile** - Update the URL to your Roblox profile (find your user ID)
- **Email** - Replace `your.email@example.com` with your email
- **GitHub** - Update the GitHub link if you have a profile

```html
<a href="https://discord.com/users/YOUR_DISCORD_ID" ...>Discord</a>
<a href="https://t.me/YOUR_TELEGRAM_USERNAME" ...>Telegram</a>
<a href="https://www.roblox.com/users/YOUR_USER_ID/profile" ...>Roblox</a>
<a href="https://github.com/Kvpll" ...>GitHub</a>
```

### 2. Add Your Projects

In the Projects section, update or add project cards:

```html
<div class="project-card">
    <div class="project-media">
        <!-- Add video embed or image URL -->
        <img src="your-image-url.jpg" alt="Project Name">
    </div>
    <div class="project-info">
        <h3>Your Project Name</h3>
        <p>Project description here</p>
        <div class="project-tags">
            <span class="tag">Technology</span>
        </div>
    </div>
</div>
```

### 3. Update Code Snippets

Replace the code card contents with your actual code examples:

```html
<div class="code-card">
    <h3>Your Code Title</h3>
    <pre><code>-- Your Lua code here
local function example()
    print("Hello")
end</code></pre>
</div>
```

### 4. Replace Placeholder Images

The project cards use placeholder images. Replace with:
- Screenshots of your games
- Videos (use `<iframe>` for YouTube/Vimeo embeds)
- GIFs of gameplay

Example for YouTube embed:
```html
<iframe width="100%" height="250" src="https://www.youtube.com/embed/VIDEO_ID" frameborder="0" allowfullscreen></iframe>
```

### 5. Customize About Section

Update the About section with:
- Your specific skills and experience
- Notable achievements
- Tools and technologies you use
- Your goals

## Hosting Options

### Local Testing
Simply open `index.html` in your browser

### Free Hosting Options
- **GitHub Pages** - Push to GitHub, enable Pages in settings
- **Vercel** - Connect your GitHub repo (one-click deployment)
- **Netlify** - Drag and drop your folder or connect GitHub
- **Replit** - Upload files and get a live URL
- **000webhost** - Free PHP hosting with file manager

### Custom Domain
Most hosting providers allow you to connect a custom domain (like kvpll.dev)

## Design Features

### Colors
- Primary (Dark): `#1f2937` - Used for headers and navigation
- Secondary (Blue): `#3b82f6` - Links and accents
- Accent (Green): `#10b981` - Highlights and hovers

### Responsive Breakpoints
- Desktop: 1200px and above
- Tablet: 768px - 1199px
- Mobile: Below 768px

### Code Style
All code is written to be:
- **Human-readable** - Clear variable names and logic flow
- **Well-organized** - Proper indentation and structure
- **Simple** - No complex frameworks or minification
- **Maintainable** - Easy to modify and extend

## Pro Tips

1. **Add Videos** - Videos showcase your work better than screenshots. Embed YouTube videos of gameplay or code walkthroughs.

2. **Keep Code Fresh** - Update code snippets regularly to show your latest and cleanest work.

3. **Project Descriptions** - Be specific about what you built and why. Highlight the problem you solved.

4. **Links Work** - Double-check all social media and external links work correctly.

5. **Mobile Test** - Always test on mobile devices to ensure responsive design works well.

6. **Performance** - Keep image file sizes small (compress before uploading).

## Technologies Used

- **HTML5** - Semantic markup
- **CSS3** - Flexbox and Grid layouts, custom properties
- **JavaScript** - Vanilla JS (no frameworks)
- **Responsive Design** - Mobile-first approach

## Next Steps

1. Update contact information with your actual details
2. Add your real project images/videos
3. Update code snippets with your best examples
4. Test on multiple devices
5. Deploy to a hosting service
6. Share your portfolio!

---

Built with clean code. Made for human developers.
