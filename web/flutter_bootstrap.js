// Custom Flutter bootstrap script for Vendura POS
(function() {
  'use strict';

  // Show loading indicator
  var loading = document.getElementById('loading');
  if (loading) {
    loading.style.display = 'flex';
  }

  // Initialize Flutter
  var script = document.createElement('script');
  script.src = 'main.dart.js';
  script.type = 'application/javascript';
  
  script.onload = function() {
    // Flutter app loaded successfully
    console.log('Vendura POS loaded successfully');
    
    // Hide loading indicator after a short delay
    setTimeout(function() {
      if (loading) {
        loading.style.opacity = '0';
        setTimeout(function() {
          loading.style.display = 'none';
        }, 300);
      }
    }, 500);
  };
  
  script.onerror = function() {
    // Handle loading error
    console.error('Failed to load Vendura POS');
    if (loading) {
      loading.innerHTML = `
        <div style="text-align: center;">
          <h1 style="color: #8B4513; margin-bottom: 20px;">Vendura POS</h1>
          <p style="color: #666; margin-bottom: 20px;">Failed to load the application.</p>
          <button onclick="location.reload()" style="
            background: #8B4513;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
          ">Retry</button>
        </div>
      `;
    }
  };
  
  document.head.appendChild(script);
})(); 