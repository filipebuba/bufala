
// Bu Fala Icons Preview JavaScript
document.addEventListener('DOMContentLoaded', function() {
    console.log('Bu Fala Icons Preview carregado');
    
    // Adicionar interatividade aos cards
    const cards = document.querySelectorAll('.icon-card');
    cards.forEach(card => {
        card.addEventListener('click', function() {
            const iconName = this.querySelector('h3').textContent;
            console.log('Ícone clicado:', iconName);
        });
    });
});
