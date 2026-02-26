const cds = require("@sap/cds");
const registerMaintenanceValidation = require("./maintenance-validation");

const STATUS_CODES = {
  AVAILABLE: "CAR_AVAILABLE",
  RENTED: "CAR_RENTED",
  UNDER_MAINTENANCE: "CAR_UNDER_MAINTENANCE",
};

module.exports = (srv) => {
  registerMaintenanceValidation(srv, cds.entities("CarRentalService"));

  const { Cars, CarCategories, CarStatuses, Maintenance, Rentals } =
    cds.entities("CarRentalService");
  const currentYear = new Date().getFullYear();
  const minYear = currentYear - 15;

  srv.before("UPDATE", "Cars.drafts", async (req) => {
    const car = req.data;
    const tx = cds.transaction(req);

    if ("licensePlate" in car) {
      const licensePlate = String(car.licensePlate || "").trim();
      if (licensePlate) {
        const existing = await tx.run(
          SELECT.one.from(Cars).columns("licensePlate").where({ licensePlate })
        );
        if (existing && existing.licensePlate !== req.data.licensePlate) {
          req.error(409, "License Plate must be unique.", "licensePlate");
        }
      }
    }

    if ("year" in car) {
      const year = Number(car.year);
      if (!Number.isInteger(year)) {
        req.error(400, "Year must be an integer.", "year");
      } else {
        if (year > currentYear)
          req.error(
            400,
            `Year must not be greater than ${currentYear}.`,
            "year"
          );
        if (year < minYear)
          req.error(400, `Cars older than 15 years are not allowed.`, "year");
      }
    }

    if ("dailyPrice" in car) {
      const price = Number(car.dailyPrice);
      if (!Number(price) || price <= 0) {
        req.error(
          400,
          "Daily Rental Price must be greater than 0.",
          "dailyPrice"
        );
      }
    }

    if ("category_code" in car) {
      if (car.category_code) {
        const category = await tx.run(
          SELECT.one
            .from(CarCategories)
            .columns("code")
            .where({ code: car.category_code })
        );
        if (!category)
          req.error(400, "Category does not exist.", "category_code");
      }
    }

    if ("status_code" in car) {
      const status = await tx.run(
        SELECT.one
          .from(CarStatuses)
          .columns("code")
          .where({ code: car.status_code })
      );
      if (!status) req.error(400, "Status does not exist.", "status_code");
    }
  });

  srv.before("SAVE", "Cars", async (req) => {
    const car = req.data || {};
    const tx = cds.transaction(req);

    const year = Number(car.year);
    if (!Number.isInteger(year)) {
      req.error(400, "Year must be an integer.", "year");
    } else {
      if (year > currentYear)
        req.error(400, `Year must not be greater than ${currentYear}.`, "year");
      if (year < minYear)
        req.error(400, "Cars older than 15 years are not allowed.", "year");
    }

    const price = Number(car.dailyPrice);
    if (!Number.isFinite(price) || price <= 0) {
      req.error(
        400,
        "Daily Rental Price must be greater than 0.",
        "dailyPrice"
      );
    }

    if (car.category_code) {
      const category = await tx.run(
        SELECT.one
          .from(CarCategories)
          .columns("code")
          .where({ code: car.category_code })
      );
      if (!category)
        req.error(400, "Category does not exist.", "category_code");
    }

    if (car.status_code) {
      const status = await tx.run(
        SELECT.one
          .from(CarStatuses)
          .columns("code")
          .where({ code: car.status_code })
      );
      if (!status) req.error(400, "Status does not exist.", "status_code");
    }

    const licensePlate = String(car.licensePlate || "").trim();
    const existing = await tx.run(
      SELECT.one.from(Cars).columns("licensePlate").where({ licensePlate })
    );
    if (existing && req.event !== "UPDATE") {
      req.error(409, "License Plate must be unique.", "licensePlate");
    }
  });

  srv.before("CREATE", "Cars.drafts", async (req) => {
    const licensePlate = String(req.data.licensePlate || "").trim();
    if (!licensePlate) return;

    const existing = await cds
      .transaction(req)
      .run(
        SELECT.one.from(Cars).columns("licensePlate").where({ licensePlate })
      );

    if (existing) {
      req.error(409, "License Plate must be unique.", "licensePlate");
    }
  });

  srv.after("READ", "Cars", async (data, req) => {
    const cars = Array.isArray(data) ? data : data ? [data] : [];
    if (!cars.length) return;

    const licensePlates = cars
      .map((car) => car.licensePlate)
      .filter((licensePlate) => Boolean(licensePlate));
    if (!licensePlates.length) return;

    const today = new Date().toISOString().slice(0, 10);
    const tx = cds.transaction(req);

    const maintenanceRecords = await tx.run(
      SELECT.from(Maintenance).columns("car_licensePlate")
        .where`car_licensePlate in ${licensePlates}
           and startDate <= ${today}
           and (endDate is null or endDate >= ${today})`
    );

    const rentalRecords = await tx.run(
      SELECT.from(Rentals)
        .columns("car_licensePlate")
        .where({ car_licensePlate: { in: licensePlates } })
        .and({ rentalDate: { "<=": today } })
        .and({ returnDate: { ">=": today } })
    );

    const maintenanceLicensePlates = new Set(
      maintenanceRecords.map((record) => record.car_licensePlate)
    );
    const rentalLicensePlates = new Set(
      rentalRecords.map((record) => record.car_licensePlate)
    );

    for (const car of cars) {
      if (maintenanceLicensePlates.has(car.licensePlate)) {
        car.status = {
          code: STATUS_CODES.UNDER_MAINTENANCE,
          name: "Under Maintenance",
          criticality: 1,
        };
      } else if (rentalLicensePlates.has(car.licensePlate)) {
        car.status = {
          code: STATUS_CODES.RENTED,
          name: "Rented",
          criticality: 2,
        };
      } else {
        car.status = {
          code: STATUS_CODES.AVAILABLE,
          name: "Available",
          criticality: 3,
        };
      }
    }
  });
};
