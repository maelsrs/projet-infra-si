document.addEventListener('DOMContentLoaded', () => {
    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');
    const uploadBtn = document.getElementById('upload-btn');
    const preview = document.getElementById('preview');
    const imagePreview = document.getElementById('image-preview');
    const uploadPrompt = document.getElementById('upload-prompt');
    const uploadStatus = document.getElementById('upload-status');
    const uploadHistory = document.getElementById('upload-history');

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, highlight, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, unhighlight, false);
    });

    function highlight() {
        dropZone.classList.add('drag-over');
    }

    function unhighlight() {
        dropZone.classList.remove('drag-over');
    }

    dropZone.addEventListener('drop', handleDrop, false);

    function handleDrop(e) {
        const dt = e.dataTransfer;
        handleFiles(dt.files);
    }

    uploadBtn.addEventListener('click', () => {
        fileInput.click();
    });

    fileInput.addEventListener('change', function() {
        handleFiles(this.files);
    });

    async function handleFiles(files) {
        if (files.length === 0) return;
        
        const file = files[0];
        if (!file.type.startsWith('image/')) {
            alert('Please upload an image file');
            return;
        }

        const reader = new FileReader();
        // reader.onload = function(e) {
        //     imagePreview.src = e.target.result;
        //     preview.classList.remove('hidden');
        //     uploadPrompt.classList.add('hidden');
        // };
        reader.readAsDataURL(file);

        // uploadStatus.classList.remove('hidden');
        try {
            const formData = new FormData();
            formData.append('image', file);

            const response = await fetch('/api/upload', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error('Upload failed');

            const data = await response.json();
            addToHistory(data.url, file.name);
        } catch (error) {
            console.error('Failed to upload:', error);
            alert('Failed to upload image. Please try again.');
        } finally {
            uploadStatus.classList.add('hidden');
            preview.classList.add('hidden');
            uploadPrompt.classList.remove('hidden');
            fileInput.value = '';
        }
    }

    function addToHistory(imageUrl, fileName) {
        const card = document.createElement('div');
        card.className = 'image-card bg-dark-800 rounded-lg overflow-hidden shadow-lg fade-in';
        
        const linkContainer = document.createElement('div');
        linkContainer.className = 'p-4 cursor-pointer hover:bg-dark-700 transition-colors duration-200';
        linkContainer.setAttribute('data-url', imageUrl);
        linkContainer.innerHTML = `
            <p class="text-sm text-gray-400 truncate">${fileName}</p>
            <p class="text-xs text-primary mt-1">${imageUrl}</p>
            <p class="text-xs text-gray-500 mt-1 opacity-0 transition-opacity duration-200">Click to copy</p>
        `;

        linkContainer.addEventListener('mouseenter', () => {
            linkContainer.querySelector('p:last-child').style.opacity = '1';
        });

        linkContainer.addEventListener('mouseleave', () => {
            linkContainer.querySelector('p:last-child').style.opacity = '0';
        });

        linkContainer.addEventListener('click', async () => {
            try {
                await navigator.clipboard.writeText(imageUrl);
                const copyText = linkContainer.querySelector('p:last-child');
                copyText.textContent = 'Copied!';
                setTimeout(() => {
                    copyText.textContent = 'Click to copy';
                }, 1500);
            } catch (err) {
                console.error('Failed to copy:', err);
            }
        });

        card.appendChild(linkContainer);
        uploadHistory.insertBefore(card, uploadHistory.firstChild);
    }
}); 