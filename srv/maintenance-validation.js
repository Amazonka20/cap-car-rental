const cds = require("@sap/cds");

module.exports = (srv, entities) => {
  const { Maintenance, Rentals } = entities;

  const overlaps = (startA, endA, startB, endB) => {
    const aStart = String(startA).slice(0, 10);
    const aEnd = String(endA ?? startA).slice(0, 10);
    const bStart = String(startB).slice(0, 10);
    const bEnd = String(endB ?? startB).slice(0, 10);
    return aStart <= bEnd && bStart <= aEnd;
  };

  const validateMaintenance = async (req) => {
    const data = req.data || {};
    const tx = cds.transaction(req);

    const startDate = data.startDate;
    const endDate = data.endDate;
    const carLicensePlate = data.car_licensePlate;

    let effectiveStartDate = startDate;
    let effectiveEndDate = endDate;

    if (effectiveStartDate == null || effectiveEndDate == null) {
        const sourceEntity = req.target;

      const currentMaintenance = await tx.run(
        SELECT.one
          .from(sourceEntity)
          .columns("ID", "startDate", "endDate", "car_licensePlate")
          .where({ ID:  data.ID })
      );

      if (currentMaintenance) {
        if (effectiveStartDate == null)
          effectiveStartDate = currentMaintenance.startDate;
        if (effectiveEndDate == null)
          effectiveEndDate = currentMaintenance.endDate;
      }
    }
    // endDate >= startDate
    if (
      effectiveStartDate &&
      effectiveEndDate &&
      String(effectiveEndDate).slice(0, 10) <
        String(effectiveStartDate).slice(0, 10)
    ) {
      req.error(
        400,
        "End Date must be greater than or equal to Start Date.",
        "endDate"
      );
      return;
    }

    // 1) Maintenance periods should not overlap with each other
    const maintenanceRows = await tx.run(
      SELECT.from(Maintenance)
        .columns("ID", "startDate", "endDate")
        .where({ car_licensePlate: carLicensePlate })
    );
    for (const row of maintenanceRows) {
      if (data.ID && row.ID === data.ID) continue;
      if (
        overlaps(
          effectiveStartDate,
          effectiveEndDate,
          row.startDate,
          row.endDate
        )
      ) {
        req.error(
          409,
          "Maintenance periods should not overlap with each other.",
          "startDate"
        );
        break;
      }
    }

    // 2) Car can not be under maintenance if it is rented (overlap check)
    const rentalRows = await tx.run(
      SELECT.from(Rentals)
        .columns("ID", "rentalDate", "returnDate")
        .where({ car_licensePlate: carLicensePlate })
    );
    
    for (const rental of rentalRows) {
      if (
        overlaps(
          effectiveStartDate,
          effectiveEndDate,
          rental.rentalDate,
          rental.returnDate
        )
      ) {
        req.error(
          409,
          "Car can not be under maintenance if it is rented. Check for overlapping with rental periods.",
          "startDate"
        );
        break;
      }
    }
  };

  srv.before("UPDATE", "Maintenance.drafts", validateMaintenance);
  srv.before("PATCH", "Maintenance.drafts", validateMaintenance);
  srv.before("SAVE", "Maintenance", validateMaintenance);
};
