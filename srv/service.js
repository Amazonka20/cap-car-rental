const cds = require("@sap/cds");
const registerMaintenanceValidation = require("./maintenance-validation");

module.exports = (srv) => {
  registerMaintenanceValidation(srv, cds.entities("CarRentalService"));

  const { Cars } = cds.entities("CarRentalService");
  const currentYear = new Date().getFullYear();
  const minYear = currentYear - 15;

  const validateCar = async (req) => {
    const car = req.data || {};

    if ("year" in car) {
      const year = Number(car.year);

      if (year > currentYear)
        req.error(400, `Year must not be greater than ${currentYear}.`, "year");
      if (year < minYear)
        req.error(400, `Cars older than 15 years are not allowed.`, "year");
    }
  };

  srv.before("CREATE", "Cars.drafts", async (req) => {
    const licensePlate = String(req.data.licensePlate || "").trim();
    if (!licensePlate) return;

    const existing = await SELECT.one
      .from(Cars)
      .columns("licensePlate")
      .where({ licensePlate });

    if (existing) {
      req.error(409, "License Plate must be unique.", "licensePlate");
    }
  });

  srv.before(["CREATE", "UPDATE"], "Cars.drafts", validateCar);
  srv.before("SAVE", "Cars", validateCar);
};
