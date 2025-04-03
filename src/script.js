// Sample project data - you can replace this with your actual projects
const projects = [
    {
        title: "Personal Portfolio Website",
        description: "A responsive portfolio website showcasing my skills and projects with modern UI/UX design principles.",
        image: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1169&q=80",
        technologies: ["HTML", "CSS", "JavaScript", "React"],
        liveLink: "#",
        repoLink: "https://github.com/CodeZobac"
    },
    {
        title: "E-commerce Platform",
        description: "A full-stack e-commerce application with user authentication, product management, and payment processing.",
        image: "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
        technologies: ["React", "Node.js", "MongoDB", "Express"],
        liveLink: "#",
        repoLink: "https://github.com/CodeZobac"
    },
    {
        title: "Weather Dashboard",
        description: "A weather application that provides real-time weather information for cities worldwide using OpenWeatherMap API.",
        image: "https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1065&q=80",
        technologies: ["JavaScript", "API", "CSS", "HTML"],
        liveLink: "#",
        repoLink: "https://github.com/CodeZobac"
    }
];

// Function to create project cards
function createProjectCards() {
    const projectsContainer = document.querySelector('.projects-container');
    
    projects.forEach(project => {
        const projectCard = document.createElement('div');
        projectCard.className = 'project-card reveal';
        
        // Create project image
        const imgElement = document.createElement('img');
        imgElement.className = 'project-image';
        imgElement.src = project.image;
        imgElement.alt = project.title;
        
        // Create project info container
        const infoContainer = document.createElement('div');
        infoContainer.className = 'project-info';
        
        // Create project title
        const titleElement = document.createElement('h3');
        titleElement.className = 'project-title';
        titleElement.textContent = project.title;
        
        // Create project description
        const descElement = document.createElement('p');
        descElement.className = 'project-description';
        descElement.textContent = project.description;
        
        // Create technologies container
        const techContainer = document.createElement('div');
        techContainer.className = 'project-tech';
        
        // Add technology tags
        project.technologies.forEach(tech => {
            const techTag = document.createElement('span');
            techTag.className = 'tech-tag';
            techTag.textContent = tech;
            techContainer.appendChild(techTag);
        });
        
        // Create links container
        const linksContainer = document.createElement('div');
        linksContainer.className = 'project-links';
        
        // Create live link
        const liveLink = document.createElement('a');
        liveLink.href = project.liveLink;
        liveLink.target = '_blank';
        liveLink.rel = 'noopener noreferrer';
        liveLink.innerHTML = '<i class="fas fa-external-link-alt"></i> Live Demo';
        
        // Create repo link
        const repoLink = document.createElement('a');
        repoLink.href = project.repoLink;
        repoLink.target = '_blank';
        repoLink.rel = 'noopener noreferrer';
        repoLink.innerHTML = '<i class="fab fa-github"></i> Repository';
        
        // Append links to links container
        linksContainer.appendChild(liveLink);
        linksContainer.appendChild(repoLink);
        
        // Append all elements to info container
        infoContainer.appendChild(titleElement);
        infoContainer.appendChild(descElement);
        infoContainer.appendChild(techContainer);
        infoContainer.appendChild(linksContainer);
        
        // Append image and info to card
        projectCard.appendChild(imgElement);
        projectCard.appendChild(infoContainer);
        
        // Append card to projects container
        projectsContainer.appendChild(projectCard);
    });
}

// Function to reveal elements when they come into view
function revealElements() {
    const reveals = document.querySelectorAll('.reveal');
    
    reveals.forEach(element => {
        const windowHeight = window.innerHeight;
        const elementTop = element.getBoundingClientRect().top;
        const elementVisible = 150;
        
        if (elementTop < windowHeight - elementVisible) {
            element.classList.add('active');
        } else {
            element.classList.remove('active');
        }
    });
}

// Add reveal class to all sections
function addRevealClass() {
    const sections = document.querySelectorAll('section');
    sections.forEach(section => {
        if (!section.classList.contains('reveal')) {
            section.classList.add('reveal');
        }
    });
}

// Set current year in the footer
function setCurrentYear() {
    const yearElement = document.getElementById('currentYear');
    if (yearElement) {
        yearElement.textContent = new Date().getFullYear();
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    setCurrentYear();
    addRevealClass();
    createProjectCards();
    revealElements();
    
    // Add scroll event listener for reveal effect
    window.addEventListener('scroll', revealElements);
});

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            window.scrollTo({
                top: targetElement.offsetTop - 100,
                behavior: 'smooth'
            });
        }
    });
});