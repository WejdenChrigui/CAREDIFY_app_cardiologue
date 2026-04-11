const express = require('express');

function createLocationRouter({ locationCollection }) {
  const router = express.Router();

  router.post('/send', async (req, res) => {
    try {
      const { latitude, longitude, altitude, accuracy, speed, timestamp, address } = req.body;

      console.log('📍 Localisation reçue:');
      console.log(`  Latitude: ${latitude}`);
      console.log(`  Longitude: ${longitude}`);
      console.log(`  Adresse: ${address}`);

      // ✅ Sauvegarde en base de données avec le driver MongoDB natif
      const locationDocument = {
        latitude,
        longitude,
        altitude,
        accuracy,
        speed,
        address: address || 'Non disponible',
        timestamp: timestamp ? new Date(timestamp) : new Date(),
        created_at: new Date()
      };

      const result = await locationCollection.insertOne(locationDocument);

      return res.status(201).json({
        success: true,
        message: 'Localisation enregistrée avec succès',
        id: result.insertedId,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('❌ Erreur:', error);
      return res.status(400).json({
        success: false,
        error: error.message
      });
    }
  });

  return router;
}

module.exports = createLocationRouter;