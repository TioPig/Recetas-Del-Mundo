package cl.duoc.api.model.converters;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

@Converter(autoApply = false)
public class StringToLocalDateTimeConverter implements AttributeConverter<String, Timestamp> {

    @Override
    public Timestamp convertToDatabaseColumn(String attribute) {
        if (attribute == null || attribute.isBlank()) return null;
        try {
            LocalDateTime ldt = LocalDateTime.parse(attribute);
            return Timestamp.valueOf(ldt);
        } catch (DateTimeParseException e) {
            // Try to parse directly as Timestamp string
            try {
                return Timestamp.valueOf(attribute);
            } catch (Exception ex) {
                return null;
            }
        }
    }

    @Override
    public String convertToEntityAttribute(Timestamp dbData) {
        if (dbData == null) return null;
        return dbData.toLocalDateTime().toString();
    }
}
