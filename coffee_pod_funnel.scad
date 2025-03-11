use <./threads-scad/threads.scad>
$fs = 0.01;
$fa = 0.1;
// VARIABLES
FIT_TOLERANCE = .1;
// Pod
POD_LID_DIAMETER = 37.10 + FIT_TOLERANCE * 3;
POD_LID_HEIGHT = 1.42;
POD_UNDER_LID_DIAMETER = 29.5 + FIT_TOLERANCE * 3;
POD_HEIGHT = 16.8 + POD_LID_HEIGHT;
POD_TIP_DIAMETER = 26.5 + FIT_TOLERANCE * 2;
// Holder
HOLDER_DIAMETER = 44.75;
HOLDER_INTERNAL_DIAMETER = POD_LID_DIAMETER + 1;
HOLDER_EXTRA_BOTTOM_HEIGHT = 10;
HOLDER_EXTRA_TOP_HEIGHT = 5;
HOLDER_SLOPE_HEIGHT = HOLDER_INTERNAL_DIAMETER - POD_LID_DIAMETER;
// Threads
THREAD_TOOTH_BASE = 2.5;
THREAD_HEIGHT = 1.15;
THREAD_ANGLE = ceil(atan((THREAD_TOOTH_BASE / 2) / THREAD_HEIGHT));
THREAD_PITCH = 4;
THREADED_PORTION_HEIGHT = 13.8;
// Magnetic pieces
MAGNETIC_ATTACHMENT_DIAMETER = 53.5;
MAGNETS_DIAMETER = 6 + FIT_TOLERANCE;
MAGNETS_HEIGHT = 2;
MAGNETS_COUNT = 8;
MAGNETS_HOLDER_HEIGHT = MAGNETS_HEIGHT + 1;
GUIDE_PINS_COUNT = MAGNETS_COUNT;
GUIDE_PINS_HEIGHT = MAGNETS_HEIGHT;
GUIDE_PINS_DIAMETER = MAGNETS_DIAMETER * .75;

/**
 * @brief Module to create a coffee pod.
 *
 * This module creates a coffee pod with a lid and a body. It allows for
 * customization of the pod's dimensions, including the diameter of the lid,
 * the diameter under the lid, the total height, the diameter of the tip, and
 * the height of the lid.
 *
 * @param lid_diameter The diameter of the pod's lid.
 * @param under_lid_diameter The diameter of the pod under the lid.
 * @param height The total height of the pod.
 * @param tip_diameter The diameter of the pod's tip.
 * @param lid_height The height of the pod's lid.
 */

module Pod(lid_diameter = POD_LID_DIAMETER, under_lid_diameter = POD_UNDER_LID_DIAMETER, height = POD_HEIGHT,
           tip_diameter = POD_TIP_DIAMETER, lid_height = POD_LID_HEIGHT)
{
    // Draw the pod body
    cylinder(h = height - lid_height, r1 = tip_diameter / 2, r2 = under_lid_diameter / 2);
    // Draw the lid
    translate_height = height - lid_height;
    translate([ 0, 0, translate_height ])
    {
        cylinder(h = lid_height, r = lid_diameter / 2);
    }
}

/**
 * @brief Module to create a threaded portion.
 *
 * This module creates a threaded portion that can be used for screwing onto
 * a coffee grinder or other devices. It allows for customization of the thread's
 * dimensions and pitch.
 *
 * @param inner_diameter The inner diameter of the threaded portion.
 * @param tooth_height The height of the thread teeth.
 * @param height The total height of the threaded portion.
 * @param pitch The pitch of the thread.
 * @param angle The angle of the thread teeth.
 * @param empty_inside_diameter The diameter of the empty space inside the thread.
 */

module Thread(inner_diameter = HOLDER_DIAMETER, tooth_height = THREAD_TOOTH_BASE, height = THREADED_PORTION_HEIGHT,
              pitch = THREAD_PITCH, angle = THREAD_ANGLE, empty_inside_diameter = HOLDER_INTERNAL_DIAMETER)
{
    difference()
    {

        ScrewThread(height = height, tolerance = FIT_TOLERANCE, tooth_height = tooth_height,
                    inner_diameter = inner_diameter, pitch = pitch, tooth_angle = angle);
        cylinder(h = height, r = empty_inside_diameter / 2);
    }
}

/**
 * @brief Module to create a holder for magnets.
 *
 * This module creates a holder for magnets, with options for adding guide pins.
 * It can be used to create a magnetic attachment for a coffee grinder or other
 * devices.
 *
 * @param magnets_count The number of magnets to hold.
 * @param height The height of the magnet holder.
 * @param magnets_diameter The diameter of the magnets.
 * @param magnets_height The height of the magnets.
 * @param diameter The outer diameter of the magnet holder.
 * @param inside_diameter The inner diameter of the magnet holder.
 * @param upside_down Whether to invert the magnet pockets.
 * @param guide_pins Whether to include guide pins ("pin" or "pocket").
 * @param guide_pins_count The number of guide pins.
 * @param guide_pins_tolerance The tolerance for the guide pins.
 * @param guide_pins_height The height of the guide pins.
 * @param guide_pins_diameter The diameter of the guide pins.
 */

module MagnetsHolder(magnets_count = MAGNETS_COUNT, height = MAGNETS_HOLDER_HEIGHT, magnets_diameter = MAGNETS_DIAMETER,
                     magnets_height = MAGNETS_HEIGHT, diameter = MAGNETIC_ATTACHMENT_DIAMETER,
                     inside_diameter = HOLDER_INTERNAL_DIAMETER, upside_down = false, guide_pins = none,
                     guide_pins_count = GUIDE_PINS_COUNT, guide_pins_tolerance = FIT_TOLERANCE,
                     guide_pins_height = GUIDE_PINS_HEIGHT, guide_pins_diameter = GUIDE_PINS_DIAMETER)
{
    // Magnets holder
    union()
    {
        // For both pins and magnets
        radius = (inside_diameter + ((diameter - inside_diameter) / 2)) / 2;
        magnets_spacing = 360 / magnets_count;
        // Ring + holes
        difference()
        {
            // Holder body
            cylinder(h = height, r = diameter / 2);
            // Hollow inside body
            cylinder(h = height, r = inside_diameter / 2);
            // Magnets pockets
            // If upside down is enabled doen't move the magnets holes to the top surface
            upside_down_translate = upside_down ? 0 : height - magnets_height;
            translate([ 0, 0, upside_down_translate ])
            {
                // Add the magnets
                for (i = [0:magnets_count - 1])
                {
                    // Space evenly the magnets
                    rotation = magnets_spacing * i;
                    // Position the magnet around the circle
                    rotate([ 0, 0, rotation ])
                    {
                        // Move outside following the radius
                        translate([ radius, 0, 0 ])
                        {
                            // Magnet pocket
                            cylinder(h = magnets_height, r = magnets_diameter / 2);
                        }
                    }
                }
                // Add the guide pins pockets
                if (guide_pins == "pocket")
                {
                    guide_pins_spacing = 360 / guide_pins_count;
                    for (i = [0:guide_pins_count - 1])
                    {
                        // Space evenly the pins and offset them form the magnets
                        rotation = (guide_pins_spacing * i) + (magnets_spacing / 2);
                        // Position the magnet around the circle
                        rotate([ 0, 0, rotation ])
                        {
                            // Move outside following the radius
                            translate([ radius, 0, 0 ])
                            {
                                // Guide pin pocket
                                cylinder(h = guide_pins_height, r = (guide_pins_diameter + guide_pins_tolerance) / 2);
                            }
                        }
                    }
                }
            }
        }
        // Guide pins
        if (guide_pins == "pin")
        {
            pins_height = guide_pins_height - 2 * guide_pins_tolerance;
            translate([ 0, 0, height ])
            {
                guide_pins_spacing = 360 / guide_pins_count;
                for (i = [0:guide_pins_count - 1])
                {
                    // Space evenly the pins and offset them form the magnets
                    rotation = (guide_pins_spacing * i) + (magnets_spacing / 2);
                    // Position the magnet around the circle
                    rotate([ 0, 0, rotation ])
                    {
                        // Move outside following the radius
                        translate([ radius, 0, 0 ])
                        {
                            // Guide pin pocket
                            cylinder(h = pins_height, r = (guide_pins_diameter - guide_pins_tolerance) / 2);
                        }
                    }
                }
            }
        }
    }
}

/**
 * @brief Module to create a magnetic coffee grinder attachment.
 *
 * This module creates an attachment designed to connect to a coffee grinder
 * magnetically. It includes a threaded portion for screwing onto the grinder
 * and a magnetic holder for secure attachment.
 *
 * @param inside_diameter The inner diameter of the attachment.
 * @param outside_diameter The outer diameter of the attachment.
 * @param threaded_portion_height The height of the threaded portion.
 */

module MagneticCoffeeGrinderAttatchment(inside_diameter = HOLDER_INTERNAL_DIAMETER, outside_diameter = HOLDER_DIAMETER,
                                        threaded_portion_height = THREADED_PORTION_HEIGHT)
{
    union()
    {
        // Threaded portion
        translate([ 0, 0, threaded_portion_height ])
        {
            // Magnets holder
            MagnetsHolder(inside_diameter = inside_diameter, guide_pins = "pocket");
        }
        Thread(height = threaded_portion_height);
    }
}

/**
 * @brief Module to create a holder for a coffee pod.
 *
 * This module creates a holder designed to fit a coffee pod, with options for
 * adding threads for a grinder attachment and/or a magnetic attachment.
 *
 * @param diameter The outer diameter of the holder.
 * @param internal_diameter The inner diameter of the holder.
 * @param extra_top_height The extra height added to the top of the holder.
 * @param extra_bottom_height The extra height added to the bottom of the holder.
 * @param pod_height The height of the coffee pod.
 * @param pod_lid_diameter The diameter of the coffee pod's lid.
 * @param slope_height The height of the slope inside the holder.
 * @param threads Whether to include threads for a grinder attachment.
 * @param magnetic_attachment Whether to include a magnetic attachment.
 * @param magnetic_attachment_merge_lip Whether to merge the magnetic attachment with a lip.
 * @param magnetic_attachment_diameter The diameter of the magnetic attachment.
 */

module PodHolder(diameter = HOLDER_DIAMETER, internal_diameter = HOLDER_INTERNAL_DIAMETER,
                 extra_top_height = HOLDER_EXTRA_TOP_HEIGHT, extra_bottom_height = HOLDER_EXTRA_BOTTOM_HEIGHT,
                 pod_height = POD_HEIGHT, pod_lid_diameter = POD_LID_DIAMETER, slope_height = HOLDER_SLOPE_HEIGHT,
                 threads = false, magnetic_attachment = true, magnetic_attachment_merge_lip = true,
                 magnetic_attachment_diameter = MAGNETIC_ATTACHMENT_DIAMETER)
{
    height = extra_top_height + extra_bottom_height + pod_height;
    union()
    {
        difference()
        {
            // Draw the empty cylinder
            difference()
            {
                // Main body
                union()
                {
                    cylinder(h = height, r = diameter / 2);
                    translate([ 0, 0, height ])
                    {
                        if (threads)
                        {
                            Thread();
                        }
                        if (magnetic_attachment)
                        {
                            MagnetsHolder(diameter = magnetic_attachment_diameter, guide_pins = "pin");
                            if (magnetic_attachment_merge_lip)
                            {
                                merge_lip_height = ((magnetic_attachment_diameter - diameter) / 2) * 1.5;
                                translate([ 0, 0, -merge_lip_height ])
                                {
                                    cylinder(h = merge_lip_height, r1 = diameter / 2,
                                             r2 = magnetic_attachment_diameter / 2);
                                }
                            }
                        }
                    }
                }
                translate([ 0, 0, height - extra_top_height ])
                {
                    translate([ 0, 0, slope_height ])
                    {
                        // Empty space on top
                        cylinder(h = extra_top_height, r = internal_diameter / 2);
                    }
                    // Slope for directing coffee inside pod
                    cylinder(h = slope_height, r2 = internal_diameter / 2, r1 = pod_lid_diameter / 2);
                }
                // Empty space bottom
                cylinder(h = extra_bottom_height, r1 = internal_diameter / 2, r2 = POD_TIP_DIAMETER / 2);
                translate([ 0, 0, extra_bottom_height ])
                {
                    Pod(height = pod_height, lid_diameter = pod_lid_diameter);
                }
            }
        }
    }
}

// Funnel only for nespresso pods
// PodHolder(magnetic_attachment = false, diameter = 60, internal_diameter = 55, extra_top_height = 15,
//           slope_height = 15);

// Funnel with threaded grinder attachment
// PodHolder(magnetic_attachment = false, threads = true);

// Grinder attachment + funnel with both magnets and pins
PodHolder();
translate([ 0, 0, 60 ]) rotate([ 0, 180, 0 ])
{
    MagneticCoffeeGrinderAttatchment();
}
