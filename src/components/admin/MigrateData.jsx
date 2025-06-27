import React, { useState } from 'react';
import { Button } from 'react-bootstrap';
import { migrateDataFromJson } from '../../utils/migrateData';

const MigrateData = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleMigration = async () => {
    setIsLoading(true);
    setMessage('Migration en cours...');
    
    try {
      const success = await migrateDataFromJson();
      if (success) {
        setMessage('Migration terminée avec succès! Vérifiez votre base de données Supabase.');
      } else {
        setMessage('Erreur lors de la migration. Vérifiez la console pour plus de détails.');
      }
    } catch (error) {
      setMessage('Erreur lors de la migration: ' + error.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="container mt-5">
      <div className="card p-4">
        <h3>Migration des données vers Supabase</h3>
        <p>Cliquez sur le bouton ci-dessous pour migrer toutes les données du fichier db.json vers votre base de données Supabase.</p>
        
        <Button 
          onClick={handleMigration} 
          disabled={isLoading}
          className="btn-g"
        >
          {isLoading ? 'Migration en cours...' : 'Migrer les données'}
        </Button>
        
        {message && (
          <div className={`alert mt-3 ${message.includes('succès') ? 'alert-success' : 'alert-info'}`}>
            {message}
          </div>
        )}
      </div>
    </div>
  );
};

export default MigrateData;